---
title: Obsidian Pandoc
author: zcysxy
type: tool
created: 2023-07-20T15:47:11
modified: 2023-10-31T05:05:11
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
> - This workflow focuses on `markdown -> latex -> pdf`. There are many great plugins for other pipelines, like [Obsidian Webpage Export](https://github.com/KosmosisDire/obsidian-webpage-export).
> - Basic knowledge of [pandoc](https://pandoc.org/), [YAML](https://yaml.org/), etc., is assumed.

Imagine your professor gives you a LaTeX template and asks you to scribe a lecture note, while you have already taken the note in Obsidian with handy features like [callouts](https://help.obsidian.md/Editing+and+formatting/Callouts) and [block links](https://help.obsidian.md/Linking+notes+and+files/Internal+links#Link+to+a+block+in+a+note), and even advanced plugins like [pseudocode](https://github.com/ytliu74/obsidian-pseudocode) and [TikZ](https://github.com/artisticat1/obsidian-tikzjax). Spend another year to type it again or do some tedious manual conversion? 😩 Never! With [one command](#3-setup-the-shell-command) within Obsidian and you are ready to submit! 🥳

![Generated PDF viewed within Obsidian](https://raw.githubusercontent.com/zcysxy/figurebed/master/img/obsidian-pandoc.png)[^1]

[^1]: Interested in the note in the figure? Check out our new preprint [Riemannian Adaptive Regularized Newton Methods with Hölder Continuous Hessians](https://arxiv.org/abs/2309.04052) 🎉

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
  - ❗ Please substitute the placeholders in the defaults file with your own configurations
- Some [templates](https://pandoc.org/MANUAL.html#templates)

## Other recommended programs

- [`cross-ref`](https://github.com/lierdakil/pandoc-crossref): Pandoc filter for cross-references
- [`mermaid-filter`](https://github.com/raghur/mermaid-filter): Pandoc filter for [Mermaid](https://mermaid-js.github.io/mermaid/#/) diagrams
- [`panrun`](https://github.com/mb21/panrun) or [my fork](https://github.com/zcysxy/panrun): read pandoc arguments from the note fromtmatter

## The workflow

### 1. Configure pandoc files

1. Install [pandoc](https://pandoc.org/installing.html) and recommended programs that suit your needs.
2. Copy the three folders `filters`, `templates`, and `defaults` to the directory you choose, e.g., `obsidian_vault/config/pandoc/`.
3. Customize the `defaults/pdf.yaml` file to configure your pandoc options and replace the placeholders.

### 2. Write the note and frontmatter

When you compose the note, it is a good practice to keep the syntax simple and compatible with pandoc and other Markdown programs.
Add meta variables in the frontmatter ([properties](https://help.obsidian.md/Editing+and+formatting/Properties)) that you want pandoc and your template to pick up, e.g.,

```yaml
---
title: Obsidian Pandoc
author: zcysxy
uni: Obsidian University # this is a variable specified in templates/scribe.tex
---
```

### 3. Setup the shell command

Now, you are ready to generate the PDF *outside* Obsidian, by running the following shell command

```bash
pandoc --defaults obsidian_vault/config/pandoc/defaults/pdf.yaml note.md
```

There are many plugins that can help you run shell commands within Obsidian, e.g., [obsidian-shellcommands](https://github.com/Taitava/obsidian-shellcommands)

### 4. Advanced configurations in the frontmatter

Under the current setup, to change a template, you can either change the `template` configuration in the defaults file or modify the shell command, adding the option `--template`.
Both methods are not ideal and break the automation.
What if we can specify the template in the frontmatter?
However, this is a limitation of the vanilla pandoc ([Issue#4627](https://github.com/jgm/pandoc/issues/4627)).

## In the future, perhaps we can

- Integrate with [obsidian-pandoc-templates](https://github.com/universvm/obsidian-pandoc-templates)
- Directly read the `preamble.sty` file used by [obsidian-latex](https://github.com/wei2912/obsidian-latex)
