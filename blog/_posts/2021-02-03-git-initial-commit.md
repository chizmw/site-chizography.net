---
layout: post
title:  "git initial-commit"
author: Chisel
categories: [blog, tech]
tags: [git, init, initial-comit, setup, howto]
date:   2021-02-03 02:03:04 +0000
description: >
   I hate repeating the same manual steps over and over again. I create new
   `git` repositories quite often. I was repeating the same manual steps for
   each I took some time out to turn it into a repeatable sub-command for
   `git`.
image:
  path:    /assets/img/blog/2021-02-03-git-initial-commit-christopher-gower.jpg
  srcset:
    1920w: /assets/img/blog/2021-02-03-git-initial-commit-christopher-gower.jpg
    960w:  /assets/img/blog/2021-02-03-git-initial-commit-christopher-gower@0,5x.jpg
    480w:  /assets/img/blog/2021-02-03-git-initial-commit-christopher-gower@0,25x.jpg
---

As a conscientious techie I hate repeating the same manual steps over and over
again. Equally so, I find I create new `git` repositories quite often. As it
became clear that I was repeating the same manual steps for each I took some
time out to turn it into a repeatable sub-command for `git`.

<!--more-->

## The Command

~~~sh
# file: "~/bin/git-initial-commit"
#!/bin/bash
set -e   # exit if any command fails

# if we haven't already initialised, do so, saves an extra manual step
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || git init

# how many commits?
commit_count=$(git rev-list --all --count)

# we want our files to go into the top-level directory ot the project
topdir=$(git rev-parse --show-toplevel)

# grab a .gitignore; assume we have curl
# (currently only writing for ourselves)
if [ -f $topdir/.gitignore ]; then
    echo "WARN: $topdir/.gitignore already exists"
else
    # now redirects somewhere else
    curl -Ls -o $topdir/.gitignore https://gitignore.io/api/git,vim,node,ruby,go
    git add $topdir/.gitignore
fi

# drop in a pre-commit config
if [ -f $topdir/.pre-commit-config.yaml ]; then
    echo "WARN: $topdir/.pre-commit-config.yaml already exists"
else
    # if we have a "preferred" config, use it, otherwise fall back to whatever
    # the default is
    if [ -f $HOME/.shellrc.d/assets/dot-pre-commit-config.yaml ]; then
        echo "INFO: copying preferred .pre-commit-config.yaml"
        cp $HOME/.shellrc.d/assets/dot-pre-commit-config.yaml $topdir/.pre-commit-config.yaml
    else
        echo "INFO: using pre-commit sample-config output"
        pre-commit sample-config > $topdir/.pre-commit-config.yaml
    fi
    git add $topdir/.pre-commit-config.yaml
    # make sure we actually use it
    pre-commit install
fi

# https://unix.stackexchange.com/a/152554
if [ "${commit_count}" -lt 1 ]; then
    git_parms=(-m 'Initial Commit (dotfiles)')
else
    git_parms=(-m 'Add dotfiles')
fi

for f in $(git diff --cached --name-only); do
    git_parms+=(-m " - add ${f}")
done

git commit "${git_parms[@]}" && git log --oneline -n 1

# vim: filetype=sh
~~~

## Attributions

- <span>Photo by <a href="https://unsplash.com/@cgower?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Christopher Gower</a> on <a href="https://unsplash.com/s/photos/coding-setup?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>

[amazon-sandisk-usb]:   https://smile.amazon.co.uk/gp/product/B07855LJ99/
[bsg-imdb]:             https://www.imdb.com/title/tt0407362/
[bsg-razor]:            https://www.imdb.com/title/tt0991178/
[bsg-viewing-order]:    https://thunderpeel2001.blogspot.com/2010/02/battlestar-galactica-viewing-order.html
[mac-homebrew]:         https://brew.sh/
[plex-library-on-usb]:  https://support.plex.tv/articles/moving-server-data-storage-location-on-nvidia-shield/
[plex-support-corrupt]: https://support.plex.tv/articles/201100678-repair-a-corrupt-database/
