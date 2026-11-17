#!/usr/bin/env python3
"""Create a GitHub branch from a Notion ticket (Select or Relation Phase).

Requires: NOTION_TOKEN, NOTION_DATABASE_ID, GITHUB_TOKEN, GITHUB_REPOSITORY,
          and NOTION_PAGE_ID (or PAGE_ID). Optional: DEFAULT_BRANCH (main).
Compatible with Notion API 2025-09-03.
"""
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

NOTION_BASE = 'https://api.notion.com/v1'
GITHUB_BASE = 'https://api.github.com'
NOTION_VERSION = '2025-09-03'


def request(method, url, headers, payload=None):
    data = json.dumps(payload).encode('utf-8') if payload is not None else None
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            raw = response.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode('utf-8', errors='replace')[:1000]
        raise RuntimeError(f'{method} {url}: HTTP {exc.code}: {detail}') from exc


def notion(method, path, payload=None):
    return request(method, NOTION_BASE + path, {
        'Authorization': 'Bearer ' + os.environ['NOTION_TOKEN'],
        'Notion-Version': NOTION_VERSION,
        'Content-Type': 'application/json',
    }, payload)


def github(method, path, payload=None):
    return request(method, GITHUB_BASE + path, {
        'Authorization': 'Bearer ' + os.environ['GITHUB_TOKEN'],
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'notion-github-bridge',
        'Content-Type': 'application/json',
    }, payload)


def slug(text):
    text = re.sub(r'[^a-z0-9]+', '_', text.lower()).strip('_')
    return text


def page_title(page):
    for prop in (page.get('properties') or {}).values():
        if prop.get('type') == 'title':
            return ''.join(part.get('plain_text', '') for part in prop.get('title', []))
    return ''


def phase_name(page):
    prop = (page.get('properties') or {}).get('Phase') or {}
    if prop.get('type') == 'select':
        return (prop.get('select') or {}).get('name', '')
    if prop.get('type') == 'relation':
        links = prop.get('relation') or []
        if not links:
            return ''
        if len(links) != 1:
            raise RuntimeError('Phase must link to exactly one phase page')
        if prop.get('has_more'):
            raise RuntimeError('Phase relation is truncated')
        related = notion('GET', '/pages/' + links[0]['id'])
        return page_title(related)
    if prop.get('type') in (None,):
        return ''
    raise RuntimeError(f'Unsupported Phase property type: {prop.get("type")}')


def update_ticket(page_id, state, link=None):
    props = {'GitHub Lifecycle': {'select': {'name': state}}}
    if link is not None:
        props['GitHub Link'] = {'url': link}
    notion('PATCH', '/pages/' + page_id, {'properties': props})


def main():
    page_id = os.environ.get('NOTION_PAGE_ID') or os.environ.get('PAGE_ID')
    if not page_id:
        raise RuntimeError('Set NOTION_PAGE_ID (or PAGE_ID) in workflow env')
    repo = os.environ['GITHUB_REPOSITORY']
    database_id = os.environ['NOTION_DATABASE_ID'].replace('-', '').lower()
    base_branch = os.environ.get('DEFAULT_BRANCH', 'main')

    page = notion('GET', '/pages/' + page_id)
    parent = page.get('parent') or {}
    # Notion 2025-09-03 database rows are parented by data_source_id.
    parent_id = (parent.get('database_id') or parent.get('data_source_id') or '').replace('-', '').lower()
    expected_source = os.environ.get('NOTION_DATA_SOURCE_ID', '').replace('-', '').lower()
    if parent_id not in {database_id, expected_source} or not parent_id:
        raise RuntimeError('Ticket does not belong to configured Notion database/data source')

    uid = ((page.get('properties') or {}).get('Ticket ID') or {}).get('unique_id') or {}
    prefix, number = uid.get('prefix'), uid.get('number')
    if not prefix or number is None:
        raise RuntimeError('Ticket ID must have a prefix and number')
    title = page_title(page)
    title_slug = slug(title)
    if not title_slug:
        raise RuntimeError('Ticket has an empty or unsupported title')
    phase_slug = slug(phase_name(page)) or 'feature'
    branch = f'{phase_slug}/{prefix}-{number}_{title_slug}'
    if not re.fullmatch(r'[a-z0-9_]+/[A-Za-z0-9-]+_[a-z0-9_]+', branch):
        raise RuntimeError('Generated branch name contains unsupported characters')

    print('Target branch:', branch)
    encoded_branch = urllib.parse.quote(branch, safe='')
    try:
        existing = github('GET', f'/repos/{repo}/git/ref/heads/{encoded_branch}')
    except RuntimeError as exc:
        if 'HTTP 404:' not in str(exc):
            raise
        existing = None

    branch_url = f'https://github.com/{repo}/tree/{encoded_branch}'
    if existing:
        print('Branch already exists; not creating duplicate')
        # Do not downgrade PR or Merged states on repeated button clicks.
        lifecycle = ((page.get('properties') or {}).get('GitHub Lifecycle') or {}).get('select') or {}
        state = lifecycle.get('name', '')
        link = ((page.get('properties') or {}).get('GitHub Link') or {}).get('url')
        if state in ('PR', 'Merged'):
            print('Keeping existing PR/Merged lifecycle')
            return
        if link and '/pull/' in link:
            print('Keeping existing PR link')
            return
        update_ticket(page_id, 'Created', branch_url)
        return

    # If the ticket already references a PR, do not create a second branch.
    existing_link = ((page.get('properties') or {}).get('GitHub Link') or {}).get('url')
    if existing_link and '/pull/' in existing_link:
        print('Ticket already links to a PR; skipping branch creation')
        return

    update_ticket(page_id, 'Processing')
    base = github('GET', f'/repos/{repo}/git/ref/heads/{urllib.parse.quote(base_branch, safe="")}')
    sha = base['object']['sha']
    github('POST', f'/repos/{repo}/git/refs', {'ref': 'refs/heads/' + branch, 'sha': sha})
    update_ticket(page_id, 'Created', branch_url)
    print('Created:', branch_url)


if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        sys.exit(1)
