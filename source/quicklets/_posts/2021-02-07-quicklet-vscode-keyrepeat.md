---
layout: post
title:  "VSCode, vim plugins and key repeat"
author: Chisel
date:   2021-02-07 19:46:36 +0100
categories: [quicklets]
description: >
    Using `vscode` and wanting key-repeat to work when you hold down a key?
image:
  path:    /assets/img/quicklets/luca-bravo-XJXWbfSo2f0-unsplash0,25x.jpg
  srcset:
    1920w: /assets/img/quicklets/luca-bravo-XJXWbfSo2f0-unsplash.jpg
    960w:  /assets/img/quicklets/luca-bravo-XJXWbfSo2f0-unsplash@0,5x.jpg
    480w:  /assets/img/quicklets/luca-bravo-XJXWbfSo2f0-unsplash@0,25x.jpg
---

If you're using the `vim` plugin with VSCode you might be frustrated when
you hold down a key and it _doesn't_ repeat.

<!--more-->

This appears to be related to OSX behaviour and not VSCode specifically.

According to [StackOverflow][so-article], and Works On My Machine™:

[so-article]: https://stackoverflow.com/questions/39972335/how-do-i-press-and-hold-a-key-and-have-it-repeat-in-vscode

~~~sh
# file: "run this in a terminal"
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
~~~

Then restart VSCode.

## Attribution

- <span>Photo by <a href="https://unsplash.com/@lucabravo?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Luca Bravo</a> on <a href="https://unsplash.com/collections/1214333/geek?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>
