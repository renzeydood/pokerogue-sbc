#!/usr/bin/env python3
"""Create a GitHub branch for a Pending Notion ticket and write back its URL."""
import json
import os
import re
import sys
import unicodedata
import urllib.error
import urllib.parse
import urllib.request

NOTION_VERSION = '2022-06-28'


def api(method, url, token, data=None, notion=False):
    headers = {'Authorization': f'Bearer {token}', 'Accept': 'application/json'}
    if notion:
        headers['Notion-Version'] = NOTION_VERSION
    else:
        headers['X-GitHub-Api-Version'] = '2022-11-28'
        headers['User-Agent'] = 'notion-github-bridge'
    if data is not None:
        headers['Content-Type'] = 'application/json'
    req = urllib.request.Request(url, data=json.dumps(data).encode() if data is not None else None,
                                 headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as res:
            body = res.read()
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode('utf-8', errors='replace')[:800]
        raise RuntimeError(f'{method} {url} failed HTTP {exc.code}: {detail}') from exc


def norm(value):
    return re.sub(r'-', '', str(value or '')).lower()


def slugify(value):
    value = unicodedata.normalize('NFKD', value).encode('ascii', 'ignore').decode().lower()
    return re.sub(r'[^a-z0-9]+', '-', value).strip('-')[:55].rstrip('-') or 'task'


def update_notion(page_id, token, **props):
    properties = {}
    if 'status' in props:
        properties['Branch Request'] = {'select': {'name': props['status']}}
    if 'url' in props:
        properties['GitHub Branch'] = {'url': props['url']}
    return api('PATCH', f'https://api.notion.com/v1/pages/{page_id}', token,
               {'properties': properties}, notion=True)


def main():
    notion_token = os.environ['NOTION_TOKEN']
    github_token = os.environ['GITHUB_TOKEN']
    repo = os.environ['GITHUB_REPOSITORY']
    page_id = os.environ['PAGE_ID'].strip()
    database_id = os.environ['NOTION_DATABASE_ID']
    prefix = os.getenv('BRANCH_PREFIX', 'PKR')
    if not re.fullmatch(r'[0-9a-fA-F-]{32,36}', page_id):
        raise ValueError('Invalid Notion page ID')

    notion_base = 'https://api.notion.com/v1'
    github_base = f'https://api.github.com/repos/{repo}'
    ticket = api('GET', f'{notion_base}/pages/{page_id}', notion_token, notion=True)
    parent = ticket.get('parent') or {}
    if norm(parent.get('database_id') or parent.get('data_source_id')) != norm(database_id):
        raise ValueError('Notion page is not in the configured database')
    props = ticket.get('properties') or {}
    state = ((props.get('Branch Request') or {}).get('select') or {}).get('name')
    if state != 'Pending':
        print(f'Ignoring ticket: Branch Request is {state!r}, not Pending.')
        return
    number = ((props.get('Ticket ID') or {}).get('unique_id') or {}).get('number')
    title = ''.join(x.get('plain_text', '') for x in (props.get('Name') or {}).get('title', []))
    if not isinstance(number, int) or number <= 0 or not title.strip():
        raise ValueError('Ticket requires a valid Ticket ID and nonempty Name')

    branch = f'feature/{prefix}-{number}-{slugify(title)}'
    encoded = urllib.parse.quote(branch, safe='')
    branch_url = f'https://github.com/{repo}/tree/{encoded}'
    print(f'Processing ticket {prefix}-{number}: {title}; branch {branch}')
    update_notion(page_id, notion_token, status='Processing')
    try:
        repo_info = api('GET', github_base, github_token)
        default = repo_info['default_branch']
        default_ref = api('GET', f'{github_base}/git/ref/heads/{urllib.parse.quote(default, safe="")}', github_token)
        sha = default_ref['object']['sha']
        try:
            api('GET', f'{github_base}/git/ref/heads/{encoded}', github_token)
            print('Branch already exists; reusing it.')
        except RuntimeError as exc:
            if 'HTTP 404:' not in str(exc):
                raise
            try:
                api('POST', f'{github_base}/git/refs', github_token,
                    {'ref': f'refs/heads/{branch}', 'sha': sha})
                print('Branch created.')
            except RuntimeError as create_exc:
                # A concurrent run may have created the exact branch.
                if 'HTTP 422:' not in str(create_exc):
                    raise
                api('GET', f'{github_base}/git/ref/heads/{encoded}', github_token)
                print('Branch already created by another run.')
        update_notion(page_id, notion_token, url=branch_url, status='Created')
        print(f'Success: {branch_url}')
        summary = os.getenv('GITHUB_STEP_SUMMARY')
        if summary:
            with open(summary, 'a', encoding='utf-8') as f:
                f.write(f'### Notion branch\n\n- Ticket: {prefix}-{number}\n- Branch: [{branch}]({branch_url})\n')
    except Exception:
        try:
            update_notion(page_id, notion_token, status='Failed')
        except Exception as update_exc:
            print(f'Could not mark ticket Failed: {update_exc}', file=sys.stderr)
        raise


if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        sys.exit(1)
