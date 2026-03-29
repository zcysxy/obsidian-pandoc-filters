---
output: 
  pdf_document: 
    defaults: defaults/pdf
    output: test.pdf
preamble: false
header-includes: 
  - \usepackage{wrapfig}
---

# Debug

## Wrapped Figures

hello
![{wrapfig=10%}](test.jpg)
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi. Proin porttitor, orci nec nonummy molestie, enim est eleifend mi, non fermentum diam nisl sit amet erat. Duis semper. Duis arcu massa, scelerisque vitae, consequat in, pretium a, enim. Pellentesque congue. 
Ut in risus volutpat libero pharetra tempor. Cras vestibulum bibendum augue. Praesent egestas leo in pede. Praesent blandit odio eu enim. Pellentesque sed dui ut augue blandit sodales. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Aliquam nibh. Mauris ac mauris sed pede pellentesque fermentum. Maecenas adipiscing ante non diam sodales hendrerit.

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
