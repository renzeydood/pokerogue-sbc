#!/usr/bin/env python3
"""Manually create a GitHub branch from a Notion Kanban ticket, then link it back."""
import json
import os
import re
import sys
import unicodedata
import urllib.error
import urllib.parse
import urllib.request

NOTION_VERSION = '2022-06-28'  # Database query API (not data-source API)


def request(method, url, token, data=None, notion=False):
    headers = {'Authorization': f'Bearer {token}', 'Accept': 'application/json'}
    if notion:
        headers['Notion-Version'] = NOTION_VERSION
    if data is not None:
        headers['Content-Type'] = 'application/json'
    req = urllib.request.Request(
        url,
        data=json.dumps(data).encode('utf-8') if data is not None else None,
        headers=headers,
        method=method,
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read()
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode('utf-8', errors='replace')[:1200]
        raise RuntimeError(f'{method} {url.split("?")[0]} failed ({exc.code}): {detail}') from exc


def title_of(page):
    for prop in page.get('properties', {}).values():
        if prop.get('type') == 'title':
            return ''.join(part.get('plain_text', '') for part in prop.get('title', []))
    return ''


def ticket_number_of(page):
    prop = page.get('properties', {}).get('Ticket ID', {})
    kind = prop.get('type')
    if kind == 'unique_id':
        return (prop.get('unique_id') or {}).get('number')
    if kind == 'number':
        return prop.get('number')
    return None


def slugify(s):
    s = unicodedata.normalize('NFKD', s)
    s = s.encode('ascii', 'ignore').decode('ascii').lower()
    s = re.sub(r'[^a-z0-9]+', '-', s).strip('-')
    return (s[:55].rstrip('-') or 'task')


def main():
    notion_token = os.environ['NOTION_TOKEN']
    github_token = os.environ['GITHUB_TOKEN']
    repo = os.environ['GITHUB_REPOSITORY']
    database_id = os.environ['NOTION_DATABASE_ID']
    prefix = os.getenv('BRANCH_PREFIX', 'PKR')
    raw = os.environ['TICKET_NUMBER'].strip()
    if not re.fullmatch(r'\d{1,8}', raw) or int(raw) < 1:
        raise ValueError('Ticket number must be a positive integer, e.g. 12')
    target = int(raw)
    notion_base = 'https://api.notion.com/v1'
    github_base = f'https://api.github.com/repos/{repo}'

    # Notion unique_id cannot be filtered in this API version; paginate safely.
    cursor = None
    matches = []
    while True:
        payload = {'page_size': 100}
        if cursor:
            payload['start_cursor'] = cursor
        page = request('POST', f'{notion_base}/databases/{database_id}/query', notion_token, payload, notion=True)
        matches.extend(p for p in page.get('results', []) if ticket_number_of(p) == target)
        if not page.get('has_more'):
            break
        cursor = page.get('next_cursor')
        if not cursor:
            raise RuntimeError('Notion returned has_more without next_cursor')
    if len(matches) != 1:
        raise RuntimeError(f'Expected one Notion ticket with Ticket ID {target}; found {len(matches)}. Check integration access and the Ticket ID property.')

    ticket = matches[0]
    title = title_of(ticket)
    if not title:
        raise RuntimeError('Ticket has no title')
    branch = f'feature/{prefix}-{target}-{slugify(title)}'
    encoded_branch = urllib.parse.quote(branch, safe='')
    branch_url = f'https://github.com/{repo}/tree/{encoded_branch}'
    print(f'Found Notion ticket: {prefix}-{target} — {title}')
    print(f'Branch: {branch}')

    repo_info = request('GET', github_base, github_token)
    default = repo_info['default_branch']
    default_ref = request('GET', f'{github_base}/git/ref/heads/{urllib.parse.quote(default, safe="")}', github_token)
    sha = default_ref['object']['sha']

    # Check exact branch name first. Avoid silently overwriting an existing branch.
    exists = False
    try:
        request('GET', f'{github_base}/git/ref/heads/{encoded_branch}', github_token)
        exists = True
    except RuntimeError as exc:
        if '(404)' not in str(exc):
            raise
    if exists:
        print('Branch already exists; will not recreate or modify it.')
    else:
        request('POST', f'{github_base}/git/refs', github_token, {'ref': f'refs/heads/{branch}', 'sha': sha})
        print('Branch created from default branch.')

    # Idempotent write-back: append only if the same link is not already present.
    blocks_url = f'{notion_base}/blocks/{ticket["id"]}/children'
    cursor = None
    linked = False
    while True:
        query = '?page_size=100'
        if cursor:
            query += '&start_cursor=' + urllib.parse.quote(cursor, safe='')
        block_page = request('GET', blocks_url + query, notion_token, notion=True)
        for block in block_page.get('results', []):
            for val in block.values():
                if isinstance(val, dict):
                    for rt in val.get('rich_text', []):
                        if rt.get('href') == branch_url or ((rt.get('text') or {}).get('link') or {}).get('url') == branch_url:
                            linked = True
                            break
        if linked or not block_page.get('has_more'):
            break
        cursor = block_page.get('next_cursor')
        if not cursor:
            raise RuntimeError('Notion blocks pagination failed')
    if not linked:
        request('PATCH', blocks_url, notion_token, {'children': [{
            'object': 'block', 'type': 'paragraph',
            'paragraph': {'rich_text': [{
                'type': 'text',
                'text': {'content': f'GitHub branch: {branch}', 'link': {'url': branch_url}},
            }]},
        }]}, notion=True)
        print('GitHub branch link added to Notion ticket page.')
    else:
        print('Notion ticket already has this branch link.')
    print(f'Notion ticket: {ticket.get("url", ticket["id"])}')
    print(f'GitHub branch: {branch_url}')
    summary = os.getenv('GITHUB_STEP_SUMMARY')
    if summary:
        with open(summary, 'a', encoding='utf-8') as f:
            f.write(f'### Branch from Notion ticket\n\n- Ticket: [{prefix}-{target}]({ticket.get("url", "")})\n- Branch: [{branch}]({branch_url})\n')


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, ValueError, KeyError, urllib.error.URLError) as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        sys.exit(1)
