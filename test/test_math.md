---
output: 
  pdf_document: 
    defaults: defaults/pdf
    output: test.pdf
# preamble: false
---

$$
\E[X]
$$

```pseudo
\begin{algorithm}
\caption{Armijo Rule} %% \label{alg:armijo}
\begin{algorithmic}
  \Input{$t_0,\alpha\in(0,1/2], \beta\in(0,1)$}
  \While{$f(x_k + t d_k) > f(x_k) + \alpha t \nabla f(x_k)^T d_k$}
    \State Set $t = \beta t$
    %% \State Set $k = \kappa t$
  \EndWhile
\end{algorithmic}
\end{algorithm}
```

The algorithm is in \ref{alg:armijo}.
