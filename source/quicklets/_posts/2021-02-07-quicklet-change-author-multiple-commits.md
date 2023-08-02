---
layout: post
title:  "Easily change the author of multiple git commits"
author: Chisel
date:   2021-02-07 19:46:36 +0100
categories: [quicklets]
description: >
    If you need to standardise your commit author or just force new commits
    to trigger gpg-gigning this one-liner should do the job.
image:
  path:    /assets/img/quicklets/luca-bravo-XJXWbfSo2f0-unsplash0,25x.jpg
  srcset:
    1920w: /assets/img/quicklets/luca-bravo-XJXWbfSo2f0-unsplash.jpg
    960w:  /assets/img/quicklets/luca-bravo-XJXWbfSo2f0-unsplash@0,5x.jpg
    480w:  /assets/img/quicklets/luca-bravo-XJXWbfSo2f0-unsplash@0,25x.jpg
---

Some days you realise you messed up `user.name` or `user.email` in your commit history.

Or maybe you just want to commit a fresh bunch of commits to trigger gpg signing.

This is the easiest method I know.

<!--more-->

Combining `rebase`'s `--interactive` and `--exec` options makes this really quick and easy.

Based on this [StackOverflow][so-article]:
~~~sh
# file: "run this in a terminal"
# change 'origin/master' to whichever SHA suits your needs
git rebase -i origin/master -x "git commit --amend --reset-author -CHEAD"
~~~

## Attribution

- <span>Photo by <a href="https://unsplash.com/@lucabravo?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Luca Bravo</a> on <a href="https://unsplash.com/collections/1214333/geek?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>


[so-article]: https://stackoverflow.com/a/25815116
