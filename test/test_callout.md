---
output: 
  pdf_document: 
    defaults: defaults/pdf
    output: test.pdf
preamble: false
---

# Callouts

> [!abstract]
>
> This is an abstract.


> [!asmp]
>
> This is an assumption.

> [!thm] Hoeffding's Inequality ^hoef
>
> Let $X_1, \dots, X_n$ be independent random variables with $a_i \leq X_i \leq b_i$ almost surely. Then for any $\epsilon > 0$,
> $$
> \mathbb{P}\left(\left|\frac{1}{n}\sum_{i=1}^n X_i - \mathbb{E}[X_i]\right| \geq \epsilon\right) \leq 2\exp\left(-\frac{2n^2\epsilon^2}{\sum_{i=1}^n (b_i - a_i)^2}\right).
> $$

> [!definition] $O$ Sample Complexity
>
> The **sample complexity** of a learning problem is the number of samples required to learn the problem to a given accuracy.


> [!rmk] Remark!
>
> Theorem [[#^hoef]] is a great theorem!


> [!important] This is an *important* message.

> [!example]
>
> This is an example.
