---
title: Obsidian Pandoc
author: zcysxy
type: tool
created: 2023-07-20T15:47:11
modified: 2023-10-31T05:14:24
output:
  pdf_document:
    defaults: pdf
sup:
  - "[[Obsidian]]"
  - "[[Pandoc]]"
state: done
---

# Pandoc Filters and an Academic Workflow for Obsidian

> [!NOTE]
>
> - This workflow focuses on `markdown -> latex -> pdf`. There are many great plugins for other pipelines, such as [Obsidian Webpage Export](https://github.com/KosmosisDire/obsidian-webpage-export).
> - Basic knowledge of [pandoc](https://pandoc.org/), [YAML](https://yaml.org/), etc., is assumed.

Imagine your professor gives you a LaTeX template and asks you to scribe a lecture note,[^3] while you have already taken the note in Obsidian with handy features like [callouts](https://help.obsidian.md/Editing+and+formatting/Callouts) and [block links](https://help.obsidian.md/Linking+notes+and+files/Internal+links#Link+to+a+block+in+a+note), and even advanced plugins like [Pseudocode](https://github.com/ytliu74/obsidian-pseudocode) and [TikZ](https://github.com/artisticat1/obsidian-tikzjax). Spend another year to type it again or do some tedious manual conversion? 😩 Never! With [one command](#3-setup-the-shell-command) within Obsidian and you are ready to submit! 🥳

![Generated PDF viewed within Obsidian](https://raw.githubusercontent.com/zcysxy/figurebed/master/img/obsidian-pandoc.png)[^1]

[^3]: Here is a [genuine compliment](https://raw.githubusercontent.com/zcysxy/obsidian-pandoc-filters/main/assets/compliment.png) from my professor on my docs generated using this workflow.
[^1]: Interested in the note in the figure? Check out our new preprint [Riemannian Adaptive Regularized Newton Methods with Hölder Continuous Hessians](https://arxiv.org/abs/2309.04052) 🎉

## This repository includes

- A [workflow](#the-workflow) that helps you seamlessly convert your Obsidian notes to camera-ready PDFs
- [Pandoc filters](https://pandoc.org/lua-filters.html) that transform Obsidian Markdown for pandoc conversion
  - `callout.lua` transforms Obsidian callouts into LaTeX environments and color boxes with labeling support
  - `link.lua` transforms wikilinks into LaTeX references, supporting heading links and block links with alias
  - `codeblock.lua` parses codeblocks for plugins, including [TikZ](https://github.com/artisticat1/obsidian-tikzjax) and [Pseudocode](https://github.com/ytliu74/obsidian-pseudocode#use-in-block-preamble)
  - `image.lua` parses image captions and attributes, supporting Obsidian image alias
  - `shift_headings.lua` shifts heading levels to avoid duplicate H1 titles, supporting customizable shift levels
  - `div.lua` transforms custom pandoc divs
  - `transclude.lua` embeds transcluded Markdown files using `\![[filename]]` syntax
  - `preamble.lua` loads your reusable preamble file, e.g., `preamble.sty` for [obsidian-latex](https://github.com/wei2912/obsidian-latex)
- A [defaults file](https://pandoc.org/MANUAL.html#defaults-files) that configures all the pandoc options and meta variables
  - ❗ Please substitute the placeholders in the defaults file with your own configurations
- Some [templates](https://pandoc.org/MANUAL.html#templates) that control the look of the generated PDF

<!-- Please refer to the [customization guide](#customization-guide) for the detailed description of these files. -->

## Other recommended programs

- Other filters
  - [`cross-ref`](https://github.com/lierdakil/pandoc-crossref): Pandoc filter for cross-references
  - [`mermaid-filter`](https://github.com/raghur/mermaid-filter): Pandoc filter for [Mermaid](https://mermaid-js.github.io/mermaid/#/) diagrams
- Pandoc wrappers
  - [`panrun`](https://github.com/mb21/panrun) or [my fork](https://github.com/zcysxy/panrun): read pandoc arguments from the note fromtmatter
- Obisidian plugin
  - [obsidian-shellcommands](https://github.com/Taitava/obsidian-shellcommands)

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

Now, you are ready to generate the PDF _outside_ Obsidian, by running the following shell command

```bash
pandoc --defaults obsidian_vault/config/pandoc/defaults/pdf.yaml note.md
```

There are many plugins that can help you run shell commands within Obsidian, e.g., [obsidian-shellcommands](https://github.com/Taitava/obsidian-shellcommands)
My obsidian-shellcommands command looks like this:

![image.png](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/20231031051316.png)

### 4. Advanced configurations in the frontmatter

Under the current setup, to change a template, you can either change the `template` configuration in the defaults file or modify the shell command, adding the option `--template`.
Both methods are not ideal and break the automation.
What if we can specify the template in the frontmatter?
However, this is a limitation of the vanilla pandoc ([Issue#4627](https://github.com/jgm/pandoc/issues/4627)).
In the issue, several programs are mentioned to solve this problem, e.g., my fork of [panrun](https://github.com/zcysxy/panrun). [^2]
With panrun, we can specify the pandoc arguments like `template` in the frontmatter:

```yaml
---
output:
  pdf_document:
    pandoc_args:
    defaults: pdf
    template: scribe.tex
---
```

And the shell command becomes

```bash
panrun note.md --data-dir obsidian_vault/config/pandoc/
```

Therefore, the actual obsidian-shellcommands command I am using looks like this:

![image.png](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/20231031051422.png)

[^2]: This fork allows configurations in the frontmatter to override the defaults file, which is not supported in the original panrun.

## In the future, perhaps we can

- Add more filters for
  - beamer
  - embeds
  - literature note links as citations
  - Obsidian comments
- Integrate with [obsidian-pandoc-templates](https://github.com/universvm/obsidian-pandoc-templates) and [obsidian-enhancing-export](https://github.com/mokeyish/obsidian-enhancing-export)
- [x] Directly read the `preamble.sty` file used by [obsidian-latex](https://github.com/wei2912/obsidian-latex)

## Customization guide

> WIP
