---
title: 'Obsidian Graph View Guide'
tags: [guide, obsidian, graph]
date: 2025-08-12
---

# Obsidian Graph View Guide

## Summary
- Tidy the graph by excluding noisy files and folders.
- Use topic hubs (tags: topic/*) to cluster notes.
- Prefer Local graph for focused exploration; use Global graph sparingly.

## Recommended exclusions (Files & Links > Excluded files)
Add these patterns to reduce non-note noise. Adjust to your vault structure.

- node_modules/
- .git/
- dist/
- build/
- out/
- assets/
- **/*.map
- **/*.lock
- **/*.log
- **/*.png
- **/*.jpg
- **/*.jpeg
- **/*.svg
- **/*.gif

Note: If you keep images within notes, skip the image extensions above.

## Global Graph tips
- Group by: tags
- Filters: tag:topic OR tag:topic/*
- Show orphans: off (toggle on when cleaning)
- Arrows: off (toggle on for dependency-like views)
- Line thickness by: none (or weight by links when exploring hubs)

## Local Graph tips
- Open a Topic hub (e.g., [[Topics/RSS]] or [[Topics/Obsidian]]) and open Local graph.
- Depth: 1–2 for clarity.
- Filters: tag:topic/* to keep hub-centric context.
- Pin the view if you want to compare multiple hubs.

## Topic hubs in this vault
- [[Topics/RSS]]
- [[Topics/Obsidian]]
- [[Topics/AI]]
- [[Topics/Productivity]]
- [[Topics/Business]]
- [[Topics/Planning]]
- [[Topics/Web Development]]
- [[Topics/Product Management]]
- [[Topics/Health]]

## Maintenance
- Append topic links: run the tag-and-link script from VS Code
  - scripts/obsidian-topic-tag-and-link.ps1
- Add new hubs: edit scripts/obsidian-topic-tag-and-link.ps1 (topic list) and re-run
- Normalize frontmatter/H1 (if needed): scripts/obsidian-normalize.ps1

## Notes
- Exclusions only affect visibility, not file storage.
- Keep topic tags in frontmatter (tags: [topic, topic/<name>]) for easy filtering and grouping.
