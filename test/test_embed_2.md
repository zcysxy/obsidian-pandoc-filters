---
output: 
  pdf_document: 
    defaults: defaults/pdf
    output: test.pdf
preamble: false
---

# Title

## Text!

this is good! ^text

### Equation

$$
F(x) = \int_{-\infty}^x e^{-t^2} dt
$$

^eq-test

## A Table


| A | B |
|---|---|
| 1 | 2 |

^table

## A Callout

> [!note] hello ^callout
>
> This is a callout box.

## A List

- item 1
    - sub-item 1
- item 2 ^list-l1
    - sub-item 2 ^list-l2
        - sub-sub-item 1
    - sub-item 3
- item 3
