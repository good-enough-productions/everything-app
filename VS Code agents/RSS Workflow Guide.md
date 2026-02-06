---
title: 'RSS Workflow Guide'
tags: [guide, rss]
created: 2025-08-13
---

# RSS Workflow Guide

This pipeline fetches RSS/Atom feeds, converts them to Markdown, and auto-tags/links them into your vault.

## Files
- scripts/obsidian-fetch-rss-list.ps1 — fetch list of feeds to JSONL
- scripts/obsidian-rss-import.ps1 — import JSONL into Feeds/YYYY/MM/*.md
- scripts/obsidian-rss-runner.ps1 — one-click runner: fetch -> import -> tag -> index
- feeds.example.txt — sample feed list

## Usage
1) Create your feed list:
   - Copy feeds.example.txt to feeds.txt and add/remove URLs.
2) Run the workflow:
   - powershell -NoProfile -ExecutionPolicy Bypass -File "...\scripts\obsidian-rss-runner.ps1"
3) Open Obsidian and browse Feeds/YYYY/MM for new items; hubs and tags are prefilled.

## Notes
- Idempotent: re-running won’t duplicate headers/links.
- Feeds hub: [[Topics/Feeds]] will collect backlinks for imported items.
- For hosted readers (Miniflux/FreshRSS), you can skip fetch and export to JSONL via their API, then run the importer.
