---
title: Obsidian Pandoc
aliases: []
type: tool
created: 2023-07-20T15:47:11
modified: 2023-10-31T01:10:44
output:
  pdf_document:
    defaults: pdf
sup:
  - "[[Obsidian]]"
  - "[[Pandoc]]"
state: "[[%wip]]"
---

# Pandoc Filters and Workflow for Obsidian

> [!NOTE] Note
> - This workflow focuses on `markdown -> latex -> pdf`. There are many great plugins for other pipelines, like [Obsidian Webpage Export](https://github.com/KosmosisDire/obsidian-webpage-export).

Imagine your professor gives you a LaTeX template and asks you to scribe a lecture note, while you have already taken the note in Obsidian with handy features like [callouts](https://help.obsidian.md/Editing+and+formatting/Callouts) and [block links](https://help.obsidian.md/Linking+notes+and+files/Internal+links#Link+to+a+block+in+a+note), and even advanced plugins like [pseudocode](https://github.com/ytliu74/obsidian-pseudocode) and [TikZ](https://github.com/artisticat1/obsidian-tikzjax). Spend another year to type it again or do some tedious manual conversion? 😩 Never! With one command within Obsidian and you are ready to submit! 🥳

![generated PDF viewed within Obsidian](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/obsidian-pandoc.png)

## This repository includes

- [Pandoc filters](https://pandoc.org/lua-filters.html)
    - `callout.lua` transforms Obsidian callouts into LaTeX environments and color boxes with labeling support
    - `link.lua` transforms wikilinks into LaTeX references, supporting heading links and block links with alias
    - `codeblock.lua` parses codeblocks for plugins, including [TikZ](https://github.com/artisticat1/obsidian-tikzjax) and [Pseudocode](https://github.com/ytliu74/obsidian-pseudocode#use-in-block-preamble)
    - `image.lua` parses image captions and attributes, supporting Obsidian image alias
    - `shift_headings.lua` shifts heading levels to avoid duplicate H1 titles, supporting customizable shift levels
    - `div.lua` transforms custom pandoc divs
    - Other planned filters for
        - beamer
        - embeds
        - literature note links as citations
- A [defaults file](https://pandoc.org/MANUAL.html#defaults-files) that configures all the pandoc options and meta variables
    - Please substitute the placeholders in the defaults file with your own configurations
- Some [templates](https://pandoc.org/MANUAL.html#templates)

## Recommendations

- cross-ref
- mermail-filter

## Defaults File

- wikilink [[#Filters]]

## LaTeX Templates and Style Files

- Extended Mathjax style file

## Shell Commands

- [GitHub - mb21/panrun: Script that looks at the YAML metadata in a markdown file and runs pandoc for you.](https://github.com/mb21/panrun)
- [Fetching Title#697c](https://github.com/jgm/pandoc/issues/4627)

## TODO
