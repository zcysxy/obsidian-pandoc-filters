---
output: 
  pdf_document: 
    defaults: defaults/pdf
    output: test.pdf
preamble: false
---

# Debug

::: hidden

The ellipse plot and the chi-square plot are reported in [@fig:ellipse] and [@fig:qq] respectively.
The results match with parts a) and b).

![Ellipse plot](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/ellipse.svg)

![{width=60% #fig:qq}](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/qq.svg)

![|300](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/ellipse.svg)

![qq|300](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/qq.svg)

![Ellipse plot {#fig:ellipse}](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/ellipse.svg)

![{width=10%}|300](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/qq.svg)

![Ellipse plot {width:30%} | 300](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/ellipse.svg)
:::

## Inline Figures

This is a test for inline figures: ![inline {width=10%}](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/ellipse.svg)

## Subplots

Lala [@fig:figureRefA;@fig:figureRefB] and [@fig:figureRef].

<div id="fig:figureRef">
![subfigure 1 caption{#fig:figureRefA width=40%}](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/qq.svg)
![subfigure 2 caption{#fig:figureRefB width=40%}|200](https://raw.githubusercontent.com/zcysxy/Figurebed/master/img/ellipse.svg)

Caption of figure
</div>
