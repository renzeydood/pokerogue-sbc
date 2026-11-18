#!/usr/bin/env python3
"""Sync GitHub pull-request and branch deletion events to Notion.

Requires NOTION_TOKEN, NOTION_DATA_SOURCE_ID (preferred), GITHUB_EVENT_PATH,
GITHUB_EVENT_NAME, GITHUB_REPOSITORY. Optional: NOTION_DATABASE_ID (legacy).
Uses Notion API 2025-09-03 for data sources or 2022-06-28 for legacy databases.
"""
import json
import logging
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

BASE = 'https://api.notion.com/v1'
LOG = logging.getLogger('notion-lifecycle')


def required_env(name):
    value = os.environ.get(name, '').strip()
    if not value:
        raise RuntimeError(f'Missing or empty environment variable: {name}')
    return value


def notion_api_settings():
    source_id = os.environ.get('NOTION_DATA_SOURCE_ID', '').strip()
    database_id = os.environ.get('NOTION_DATABASE_ID', '').strip()
    if source_id:
        identifier = validate_uuid(source_id, 'NOTION_DATA_SOURCE_ID')
        return '2025-09-03', f'/data_sources/{identifier}/query'
    if database_id:
        identifier = validate_uuid(database_id, 'NOTION_DATABASE_ID')
        LOG.warning('Using legacy database query endpoint. Set NOTION_DATA_SOURCE_ID to use current API.')
        return '2022-06-28', f'/databases/{identifier}/query'
    raise RuntimeError('Set NOTION_DATA_SOURCE_ID (preferred) or NOTION_DATABASE_ID in GitHub Actions variables')


def validate_uuid(value, name):
    normalized = value.replace('-', '')
    if not re.fullmatch(r'[0-9a-fA-F]{32}', normalized):
        raise RuntimeError(f'{name} must be a Notion UUID, not a URL or collection:// URI')
    return value


def notion(method, path, version, payload=None):
    # All paths are constructed internally; never include tokens in URLs or logs.
    url = BASE + path
    headers = {
        'Authorization': 'Bearer ' + required_env('NOTION_TOKEN'),
        'Notion-Version': version,
        'Content-Type': 'application/json',
    }
    body = json.dumps(payload).encode('utf-8') if payload is not None else None
    LOG.info('Notion request: %s %s (API %s)', method, url, version)
    req = urllib.request.Request(url, headers=headers, method=method, data=body)
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            LOG.info('Notion response: HTTP %s', response.status)
            return json.load(response)
    except urllib.error.HTTPError as exc:
        error_body = exc.read().decode('utf-8', errors='replace')
        # Notion error payloads may include request metadata; no auth headers logged.
        LOG.error('Notion request failed: HTTP %s %s %s', exc.code, method, url)
        LOG.error('Notion error response: %s', error_body[:1000])
        raise RuntimeError(f'Notion HTTP {exc.code} ({method} {path})') from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f'Notion network error ({method} {path}): {exc.reason}') from exc


def find_ticket(prefix, number, version, query_path):
    cursor = None
    page_count = 0
    while True:
        payload = {'page_size': 100}
        if cursor:
            payload['start_cursor'] = cursor
        result = notion('POST', query_path, version, payload)
        page_count += 1
        pages = result.get('results', [])
        LOG.info('Ticket lookup page %s: %s records', page_count, len(pages))
        for page in pages:
            uid = (page.get('properties', {}).get('Ticket ID', {}).get('unique_id') or {})
            if (uid.get('prefix') or '').casefold() == prefix.casefold() and uid.get('number') == number:
                LOG.info('Matched ticket %s-%s to Notion page %s', prefix, number, page['id'])
                return page
        if not result.get('has_more'):
            LOG.warning('Ticket %s-%s not found after %s pages', prefix, number, page_count)
            return None
        cursor = result.get('next_cursor')
        if not cursor:
            raise RuntimeError('Notion pagination cursor missing')


def main():
    version, query_path = notion_api_settings()
    event_path = required_env('GITHUB_EVENT_PATH')
    kind = required_env('GITHUB_EVENT_NAME')
    repo = required_env('GITHUB_REPOSITORY')
    LOG.info('Lifecycle event=%s repo=%s query_endpoint=%s api_version=%s', kind, repo, query_path, version)
    with open(event_path, encoding='utf-8') as stream:
        event = json.load(stream)
    if kind == 'pull_request':
        pr = event['pull_request']
        head_repo = (pr.get('head', {}).get('repo') or {}).get('full_name', '')
        if head_repo.lower() != repo.lower():
            LOG.info('Ignoring fork pull request')
            return
        branch = pr['head']['ref']
        action = event['action']
        if action in ('opened', 'reopened'):
            new_status = 'PR'
        elif action == 'closed' and pr.get('merged'):
            new_status = 'Merged'
        else:
            LOG.info('Ignoring unmerged PR closure or unrelated PR action=%s', action)
            return
        link = pr['html_url']
    elif kind == 'delete' and event.get('ref_type') == 'branch':
        branch = event['ref']
        new_status = 'Deleted'
        link = None
    else:
        LOG.info('Ignoring event type=%s', kind)
        return

    LOG.info('Event action=%s branch=%s desired_lifecycle=%s', event.get('action', 'n/a'), branch, new_status)
    match = re.fullmatch(r'[a-z0-9_]+/([A-Za-z0-9]+)-(\d+)_[A-Za-z0-9_]+', branch)
    if not match:
        LOG.info('Ignoring branch outside Notion naming convention')
        return
    prefix, number = match.group(1), int(match.group(2))
    page = find_ticket(prefix, number, version, query_path)
    if not page:
        return
    page_id = page['id']
    props = page.get('properties') or {}
    state = (props.get('GitHub Lifecycle', {}).get('select') or {}).get('name')
    current_link = (props.get('GitHub Link', {}) or {}).get('url')
    LOG.info('Current Notion lifecycle=%s has_link=%s', state, bool(current_link))
    if state == 'Merged' and new_status != 'Merged':
        LOG.info('Already merged; ignoring later event')
        return
    if new_status == 'Deleted' and (state == 'PR' or (current_link and '/pull/' in current_link)):
        LOG.info('PR exists; retaining PR lifecycle and link')
        return
    if state == new_status and (link is None or current_link == link):
        LOG.info('No change needed')
        return
    update = {'GitHub Lifecycle': {'select': {'name': new_status}}}
    if link:
        update['GitHub Link'] = {'url': link}
    notion('PATCH', f'/pages/{page_id}', version, {'properties': update})
    LOG.info('Updated %s-%s: %s', prefix, number, new_status)


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s', stream=sys.stdout)
    try:
        main()
    except Exception as exc:
        LOG.error('%s', exc)
        sys.exit(1)
