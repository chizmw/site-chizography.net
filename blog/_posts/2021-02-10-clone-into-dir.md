---
layout: post
title:  "Organised Git Checkouts"
author: Chisel
date:   2021-02-10 19:46:36 +0100
categories: [blog, tech]
tags: [git]
description: >
    It's all too easy to just check out git repositories wherever you are at
    the time you want it. This becomes unweildy once you have a few repos on
    the go. This article combines laziness and structure to live a more
    organised (git repo) lifestyle.
image:
  path:    /assets/img/blog/2021-02-10-clone-into-dir.png
  srcset:
    1920w: /assets/img/blog/2021-02-10-clone-into-dir.png
    960w:  /assets/img/blog/2021-02-10-clone-into-dir@0,5x.png
    480w:  /assets/img/blog/2021-02-10-clone-into-dir@0,25x.png
---

{% include read-estimate.md %}

It's all too easy to just check out git repositories wherever you are at the
time you want it. This becomes unweildy once you have a few repos on the go.
This article combines laziness and structure to live a more organised (git
repo) lifestyle.

<!--more-->

* this unordered seed list will be replaced by the toc
{:toc}

## The Explanation

By default `clone-into-dir` will use `~/development` as the root location for
all clone actions.

If you prefer to have your code somewhere else you can set a variable in your
shell:

~~~sh
export CLONEINTO_ROOT=/path/to/your/preference
~~~

It will create relevant subdirectories, and clone the remote repository for
you there.

For example, `git@github.com:chiselwright/shellrcd-extras-chizcw.git` will
ensure into `~/development/chiselwright/` exists then clone the repository
into `shellrcd-extras-chizcw` in that location.

Assuming that succeeds, the script will check to see if you have `code` (the
wrapper script that launches VSCode) and open the new repository for you
automatically.

## The Script

Save this into your path (e.g. `~/bin`).

~~~bash
# file: "clone-into-dir"
#!/bin/bash
set -euo pipefail

# if you don't like ~/develpment simply:
#   export CLONEINTO_ROOT=/path/to/your/preference
rootDir=${CLONEINTO_ROOT:-~/development}
cloneURL="${1:?missing git clone url}"

# make sure the rootDir exists, and go there
mkdir -p "${rootDir}"
cd "${rootDir}"

# anything that looks like a remote git repo
pattern='^.+:(.*)/(.*).git$'

if [[ "$cloneURL" =~ $pattern ]]; then
    if [ -d "${rootDir}/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}" ]; then
        echo "# project already exists: ${rootDir}/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    else
        echo "# cloning ${cloneURL} into ${rootDir}/${BASH_REMATCH[1]}…"
        mkdir -p "${BASH_REMATCH[1]}"
        git -C "${BASH_REMATCH[1]}" clone "${cloneURL}"
        echo "# repository cloned to: ${rootDir}/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    fi
else
    echo "# unsupported git uri: $cloneURL"
fi

# if we find VSCode, open the new repo
if type code >/dev/null; then
    if [ -d "${rootDir}/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}" ]; then
        echo "# opening ${rootDir}/${BASH_REMATCH[1]}/${BASH_REMATCH[2]} in VSCode…"
        code "${rootDir}/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    fi
fi
~~~

## Source

Just in case the script moves on after the artice is published,
[here's the source file][github-homebin-cloneintodir]


[github-homebin-cloneintodir]: https://github.com/chiselwright/shellrcd-extras-chizcw/blob/extras/chizcw/home-bin/clone-into-dir
