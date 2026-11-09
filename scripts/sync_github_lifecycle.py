#!/usr/bin/env python3
"""Sync GitHub PR and branch-deletion events to a Notion ticket."""
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

NOTION_VERSION = '2022-06-28'
BASE = 'https://api.notion.com/v1'

def notion(method, path, payload=None):
    headers = {'Authorization': 'Bearer ' + os.environ['NOTION_TOKEN'],
               'Notion-Version': NOTION_VERSION, 'Content-Type': 'application/json'}
    req = urllib.request.Request(BASE + path, headers=headers, method=method,
        data=json.dumps(payload).encode() if payload is not None else None)
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            return json.load(response)
    except urllib.error.HTTPError as exc:
        raise RuntimeError(f'Notion HTTP {exc.code}: {exc.read().decode()[:500]}') from exc

def find_ticket(prefix, number):
    # Paginate rather than relying on unsupported unique_id filtering.
    cursor = None
    database_id = os.environ['NOTION_DATABASE_ID']
    while True:
        payload = {'page_size': 100}
        if cursor:
            payload['start_cursor'] = cursor
        result = notion('POST', f'/databases/{database_id}/query', payload)
        for page in result.get('results', []):
            uid = (page.get('properties', {}).get('Ticket ID', {}).get('unique_id') or {})
            if uid.get('prefix') == prefix and uid.get('number') == number:
                return page
        if not result.get('has_more'):
            return None
        cursor = result.get('next_cursor')
        if not cursor:
            raise RuntimeError('Notion pagination cursor missing')

def main():
    with open(os.environ['GITHUB_EVENT_PATH'], encoding='utf-8') as f:
        event = json.load(f)
    kind = os.environ['GITHUB_EVENT_NAME']
    repo = os.environ['GITHUB_REPOSITORY']
    if kind == 'pull_request':
        pr = event['pull_request']
        if pr['head']['repo']['full_name'].lower() != repo.lower():
            print('Ignoring fork pull request')
            return
        branch = pr['head']['ref']
        action = event['action']
        if action in ('opened', 'reopened'):
            new_status = 'PR'
        elif action == 'closed' and pr.get('merged'):
            new_status = 'Merged'
        else:
            print('Ignoring unmerged PR closure; branch may still exist')
            return
        link = pr['html_url']
    elif kind == 'delete' and event.get('ref_type') == 'branch':
        branch = event['ref']
        new_status = 'Deleted'
        link = None
    else:
        print('Ignoring event')
        return
    match = re.fullmatch(r'feature/([A-Za-z0-9]+)-(\d+)_[A-Za-z0-9_]+', branch)
    if not match:
        print('Ignoring branch outside Notion naming convention')
        return
    prefix, number = match.group(1), int(match.group(2))
    page = find_ticket(prefix, number)
    if not page:
        print(f'No Notion ticket for {prefix}-{number}')
        return
    page_id = page['id']
    props = page.get('properties') or {}
    state = (props.get('GitHub Lifecycle', {}).get('select') or {}).get('name')
    current_link = (props.get('GitHub Link', {}) or {}).get('url')
    # Never downgrade a merged PR to Deleted after GitHub removes its branch.
    if state == 'Merged' and new_status != 'Merged':
        print('Ticket already merged; ignoring later event')
        return
    if new_status == 'Deleted' and (state == 'PR' or (current_link and '/pull/' in current_link)):
        print('PR link exists; retain PR lifecycle despite branch deletion')
        return
    # Do not let a late/reopened event overwrite an already merged ticket.
    if state == new_status and (link is None or current_link == link):
        print('No change needed')
        return
    update = {'GitHub Lifecycle': {'select': {'name': new_status}}}
    if link:
        update['GitHub Link'] = {'url': link}
    elif new_status == 'Deleted':
        update['GitHub Link'] = {'url': None}
    notion('PATCH', f'/pages/{page_id}', {'properties': update})
    print(f'Updated {prefix}-{number}: {new_status}')

if __name__ == '__main__':
    try:
        main()
    except Exception as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        sys.exit(1)
