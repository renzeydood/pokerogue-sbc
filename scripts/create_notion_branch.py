#!/usr/bin/env python3
"""Idempotent Notion ticket -> GitHub branch; reusable across repositories."""
import json
import os
import re
import sys
import unicodedata
import urllib.error
import urllib.parse
import urllib.request

NOTION_VERSION = '2022-06-28'

class APIError(RuntimeError):
    def __init__(self, status, message):
        super().__init__(f'HTTP {status}: {message[:500]}')
        self.status = status

def api(method, url, token, data=None, notion=False):
    headers = {'Authorization': f'Bearer {token}', 'Accept': 'application/json'}
    if notion:
        headers['Notion-Version'] = NOTION_VERSION
    else:
        headers.update({'X-GitHub-Api-Version': '2022-11-28', 'User-Agent': 'notion-github-bridge'})
    if data is not None:
        headers['Content-Type'] = 'application/json'
    req = urllib.request.Request(url, data=json.dumps(data).encode() if data is not None else None,
                                 headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as res:
            body = res.read()
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as exc:
        raise APIError(exc.code, exc.read().decode('utf-8', 'replace')) from exc

def norm(v):
    return str(v or '').replace('-', '').lower()

def slug(v, limit=55):
    v = unicodedata.normalize('NFKD', str(v)).encode('ascii', 'ignore').decode().lower()
    return re.sub(r'[^a-z0-9]+', '_', v).strip('_')[:limit].rstrip('_') or 'task'

def notion_update(page_id, token, status, link=None):
    properties = {'GitHub Lifecycle': {'select': {'name': status}}}
    if link is not None:
        properties['GitHub Link'] = {'url': link}
    api('PATCH', f'https://api.notion.com/v1/pages/{page_id}', token,
        {'properties': properties}, notion=True)

def get_or_none(url, token):
    try:
        return api('GET', url, token)
    except APIError as exc:
        if exc.status == 404:
            return None
        raise

def main():
    notion_token = os.environ['NOTION_TOKEN']
    github_token = os.environ['GITHUB_TOKEN']
    repo = os.environ['GITHUB_REPOSITORY']
    page_id = os.environ['PAGE_ID'].strip()
    database_id = os.environ['NOTION_DATABASE_ID']
    if not re.fullmatch(r'[0-9a-fA-F-]{32,36}', page_id):
        raise ValueError('Invalid Notion page ID')
    nb = 'https://api.notion.com/v1'
    gb = f'https://api.github.com/repos/{repo}'
    page = api('GET', f'{nb}/pages/{page_id}', notion_token, notion=True)
    parent = page.get('parent') or {}
    if norm(parent.get('database_id') or parent.get('data_source_id')) != norm(database_id):
        raise ValueError('Ticket does not belong to this repository’s configured Notion database')
    props = page.get('properties') or {}
    state = ((props.get('GitHub Lifecycle') or {}).get('select') or {}).get('name')
    if state != 'Pending':
        print(f'No action: current lifecycle {state!r}')
        return
    uid = (props.get('Ticket ID') or {}).get('unique_id') or {}
    number, prefix = uid.get('number'), uid.get('prefix')
    title = ''.join(x.get('plain_text', '') for x in (props.get('Name') or {}).get('title', []))
    if not isinstance(number, int) or number <= 0 or not prefix or not re.fullmatch(r'[A-Za-z0-9]+', prefix) or not title.strip():
        raise ValueError('Ticket needs valid Ticket ID (with prefix) and Name')
    ticket_id = f'{prefix}-{number}'
    phase = ((props.get('Phase') or {}).get('select') or {}).get('name') or 'feature'
    branch = f'{slug(phase, 35)}/{ticket_id}_{slug(title)}'
    branch_url = f'https://github.com/{repo}/tree/{urllib.parse.quote(branch, safe="")}'
    existing_link = (props.get('GitHub Link') or {}).get('url') or ''

    # A previous PR URL is the strongest record of work. Never overwrite it with a branch.
    pr_match = re.fullmatch(rf'https://github\.com/{re.escape(repo)}/pull/(\d+)/?', existing_link, re.I)
    if pr_match:
        pr = get_or_none(f'{gb}/pulls/{pr_match.group(1)}', github_token)
        if pr:
            status = 'Merged' if pr.get('merged') else ('PR' if pr.get('state') == 'open' else 'Created')
            if status in ('Merged', 'PR'):
                notion_update(page_id, notion_token, status, pr['html_url'])
                print(f'Restored existing PR state: {status} {pr["html_url"]}')
                return
            # Closed without merge: preserve historical PR link; don't create another branch automatically.
            notion_update(page_id, notion_token, 'Created', pr['html_url'])
            print('PR closed without merge; preserved link; no new branch created')
            return

    # Existing branch URL may have a different name from the current title/phase.
    branch_match = re.fullmatch(rf'https://github\.com/{re.escape(repo)}/tree/(.+)', existing_link, re.I)
    if branch_match:
        prior_branch = urllib.parse.unquote(branch_match.group(1))
        if re.fullmatch(r'[^\s]+', prior_branch):
            branch = prior_branch
            branch_url = existing_link

    # Check PRs for the branch even if Notion's link was accidentally changed.
    pulls = api('GET', f'{gb}/pulls?state=all&head={urllib.parse.quote(repo.split("/")[0] + ":" + branch, safe="")}&per_page=100', github_token)
    relevant = [p for p in pulls if p.get('head', {}).get('ref') == branch and
                p.get('head', {}).get('repo', {}).get('full_name', '').lower() == repo.lower()]
    merged = next((p for p in relevant if p.get('merged_at')), None)
    opened = next((p for p in relevant if p.get('state') == 'open'), None)
    if merged or opened:
        pr = merged or opened
        status = 'Merged' if merged else 'PR'
        notion_update(page_id, notion_token, status, pr['html_url'])
        print(f'Restored existing {status} PR: {pr["html_url"]}')
        return
    if relevant:
        print('Previous PR was closed without merge; not creating another branch')
        notion_update(page_id, notion_token, 'Created', relevant[0]['html_url'])
        return

    encoded = urllib.parse.quote(branch, safe='')
    existing_ref = get_or_none(f'{gb}/git/ref/heads/{encoded}', github_token)
    if existing_ref:
        print('Branch exists; reusing it')
        notion_update(page_id, notion_token, 'Created', branch_url)
        return

    # If a branch was previously deleted, require a deliberate new ticket instead of silently recreating it.
    if existing_link:
        print('Previous GitHub link exists but branch is missing; no new branch created')
        notion_update(page_id, notion_token, 'Deleted', existing_link)
        return

    notion_update(page_id, notion_token, 'Processing')
    try:
        default = api('GET', gb, github_token)['default_branch']
        ref = api('GET', f'{gb}/git/ref/heads/{urllib.parse.quote(default, safe="")}', github_token)
        try:
            api('POST', f'{gb}/git/refs', github_token,
                {'ref': f'refs/heads/{branch}', 'sha': ref['object']['sha']})
            print('Branch created')
        except APIError as exc:
            if exc.status != 422 or not get_or_none(f'{gb}/git/ref/heads/{encoded}', github_token):
                raise
            print('Branch created concurrently; reusing it')
        # PR events may race this writeback; do not downgrade PR/Merged.
        fresh = api('GET', f'{nb}/pages/{page_id}', notion_token, notion=True)
        fresh_status = ((fresh.get('properties', {}).get('GitHub Lifecycle') or {}).get('select') or {}).get('name')
        if fresh_status not in ('PR', 'Merged'):
            notion_update(page_id, notion_token, 'Created', branch_url)
        print(f'Success: {branch_url}')
    except Exception:
        try:
            fresh = api('GET', f'{nb}/pages/{page_id}', notion_token, notion=True)
            current = ((fresh.get('properties', {}).get('GitHub Lifecycle') or {}).get('select') or {}).get('name')
            if current not in ('PR', 'Merged'):
                notion_update(page_id, notion_token, 'Failed')
        except Exception as exc:
            print(f'Unable to mark Failed: {exc}', file=sys.stderr)
        raise

if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        sys.exit(1)
