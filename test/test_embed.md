---
output: 
  pdf_document: 
    defaults: defaults/pdf
    output: test.pdf
preamble: false
---

# Test

![[test/test_embed_2#^list-l1]]

![[test/test_embed_2#^list-l2|naked]]

hello ![[test/test_embed_2#^list-l2|inline]] lala

![[test/test_embed_2#^table]]

![[test/test_embed_2#^callout]]

![[test/test_embed_2#^text|naked]]

![[test/test_embed_2#^text]]

Hello ![[test/test_embed_2#^text|inline]] write some text here.

Hello ![[test/test_embed_2#^text]] write some text here.

Hello ![[test/test_embed_2#^eq-test]] write some text here.


Hello ![[test/test_embed_2]] write some text here.

Hello ![[test/test_embed_2#text]] write some text here.

Hello ![[test/test_embed_2#a-table|naked]] write some text here.

Hello ![[test/test_embed_2|naked]] write some text here.

Hello ![[assets/compliment.png]] write some text here.
