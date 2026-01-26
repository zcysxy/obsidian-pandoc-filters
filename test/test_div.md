---
output: 
  pdf_document: 
    defaults: defaults/pdf
    output: test.pdf
preamble: false
---

# Divs

## Columns

:::: columns

::: column

hello

:::

::: column

world

:::

::: column

lala

:::
::::


## LaTeX Environments

::: {env=definition title=Greeting}

hello

:::

::: {env=theorem}

hello

:::

## Obsidian Comments

hello %% hide `this` %% world %% hide **that** %% lala %% hide *other*

%%

Hidden paragraph 1

Hidden paragraph 2

%%

Normal paragraph 1.

%%

Hidden paragraph 3

Hidden paragraph 4

%%

Normal paragraph 2.
