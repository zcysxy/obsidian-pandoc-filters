---
title: Obsidian Pandoc
type: tool
created: 2023-07-20T15:47:11
modified: 2023-10-31T04:24:13
output:
  pdf_document:
    defaults: pdf
sup:
  - "[[Obsidian]]"
  - "[[Pandoc]]"
state: "[[%wip]]"
---

# Pandoc Filters and an Academic Workflow for Obsidian

> [!NOTE]
> This workflow focuses on `markdown -> latex -> pdf`. There are many great plugins for other pipelines, like [Obsidian Webpage Export](https://github.com/KosmosisDire/obsidian-webpage-export).

Imagine your professor gives you a LaTeX template and asks you to scribe a lecture note, while you have already taken the note in Obsidian with handy features like [callouts](https://help.obsidian.md/Editing+and+formatting/Callouts) and [block links](https://help.obsidian.md/Linking+notes+and+files/Internal+links#Link+to+a+block+in+a+note), and even advanced plugins like [pseudocode](https://github.com/ytliu74/obsidian-pseudocode) and [TikZ](https://github.com/artisticat1/obsidian-tikzjax). Spend another year to type it again or do some tedious manual conversion? 😩 Never! With [one command](#2-setup-the-shell-command) within Obsidian and you are ready to submit! 🥳

<figure>
    <img src="https://raw.githubusercontent.com/zcysxy/figurebed/master/img/obsidian-pandoc.png" alt="illustration">
    <center><figcaption style="font-size=0.8em; color=gray">generated PDF viewed within Obsidian</figcaption></center>
</figure>

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

## Other recommended programs

- [`cross-ref`](https://github.com/lierdakil/pandoc-crossref): Pandoc filter for cross-references
- [`mermaid-filter`](https://github.com/raghur/mermaid-filter): Pandoc filter for [Mermaid](https://mermaid-js.github.io/mermaid/#/) diagrams
- [`panrun`](https://github.com/mb21/panrun) or [my fork](https://github.com/zcysxy/panrun): read pandoc arguments from the note fromtmatter

## The workflow

### 1. Configure pandoc files

### 2. Setup the shell command

- [Fetching Title#697c](https://github.com/jgm/pandoc/issues/4627)

## Perhaps we can

- Integrate with [obsidian-pandoc-templates](https://github.com/universvm/obsidian-pandoc-templates)
- Directly read the `preamble.sty` file used by [obsidian-latex](https://github.com/wei2912/obsidian-latex)
