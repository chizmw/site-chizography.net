---
layout: post
title: "Create New Golang Projects"
author: Chisel
date: 2021-02-12 10:23:00 +0100
categories: [blog, tech]
tags: [git]
description: >
  Continuing our desire to be ~~lazy~~ efficient and automate common tasks,
  this is about a little helper for any new golang projects we create.
image:
  path: /assets/img/blog/2021-02-12-new-golang-project-code-gaussian.png
  srcset:
    1920w: /assets/img/blog/2021-02-12-new-golang-project-code-gaussian.png
    960w: /assets/img/blog/2021-02-12-new-golang-project-code-gaussian@0,5x.png
    480w: /assets/img/blog/2021-02-12-new-golang-project-code-gaussian@0,25x.png
---

{% include read-estimate.md %}

Continuing our desire to be ~~lazy~~ efficient and automate common tasks,
this is about a little helper for any new golang projects we create.

<!--more-->

- this unordered seed list will be replaced by the toc
  {:toc}

## The Explanation

I started learning, and using, `golang` in late-2020. As my familiarity
increased I realised I was repeating the same boring steps each time I
created a new repository. Being who I am, I couldn't keep repeating myself,
so I wrote a script to repeat myself for me.

Because I wrote the script for myself it does make some assumptions, some of
which you can override, some of which you're stuck with unless you modify the
script.

Assuming everything succeeds, the script will check to see if you have `code`
(the wrapper script that launches VSCode) and open the new repository for you
automatically.

## The Script

Save this into your path (e.g. `~/bin`).

```bash
# file: "new-golang-project"
#!/bin/bash
set -euo pipefail

# grab $1 as the "original module name"
origname="${1:?missing reponame}"

# start with reponame as the origname, then prefix with go- if we don't have it
reponame="${origname}"
[[ $reponame =~ ^go- ]] || reponame="go-${reponame}"
# and trimname, get the reponame without the go-prefix; useful for packages
trimname="${reponame/go-/}"
# also, we don't want dashes!
trimname="${trimname//-/}"

# set a couple of things we may wish to make more configurable down the line:

## a github username (default: chizmw)
githubUsername="${GITHUB_USERNAME:-chizmw}"

## the module name prefix (default: github.com/${githubuserName})
gomodPrefix="${NEWGO_MODPREFIX:-github.com/${githubUsername}/}"

## cloneRoot is the base for "development" checkouts (default: ~/development)
### we use CLONEINTO_ROOT as that matches what we're using in git-initial-commit
cloneRoot="${CLONEINTO_REPO:-~/development}"

## pathPrefix .. appends the username to the cloneRoot
pathPrefix=${cloneRoot}/${githubUsername}
# expand any ~
# https://stackoverflow.com/questions/3963716/how-to-manually-expand-a-special-variable-ex-tilde-in-bash/27485157#27485157
pathPrefix="${pathPrefix/#\~/$HOME}"

# if we already exist, don't do anything
if [ -d "${pathPrefix}/${reponame}" ]; then
	echo "# repository dorectory '${pathPrefix}/${reponame}' already exists"
else
	mkdir -p "${pathPrefix}/${reponame}"
	cd "${pathPrefix}/${reponame}"

	# run our magical little repo creator
	git initial-commit

	# initialise the go module
	go mod init ${gomodPrefix}${reponame}
	git add go.mod
	git commit -v --no-verify -m "go mod init ${gomodPrefix}${reponame}"

	# create a shell of a main.go, to give us something to test with
	mkdir -p cmd/cli-client
	cat <<EOF >cmd/cli-client/main.go
package main

import (
	"fmt"

	${trimname} "${gomodPrefix}${reponame}"
)

func main() {
	// do nothing exciting ... for now
	fmt.Println(${trimname}.Global)
}
EOF

	# create a simple initial module for main.go to work
	cat <<EOF >${trimname}.go
package ${trimname}

// Global is just a thing you should delete
var Global string = "Hello World"
EOF

	cat <<EOF >README.md
# ${reponame}

## Installation

~~~sh
go get ${gomodPrefix}${reponame}
~~~

## cli-client

You can experiment with the library by running:

~~~sh
go run ./cmd/cli-client/main.go
~~~
EOF

	git add .
	git commit -m 'Skeleton files'

	# if it were just me, I'd just use `git tt` here, but let's have a fallback
	# for people that aren't me
	git tt 2>/dev/null ||
		git log --decorate \
			--pretty=format:'%Cred%h %C(blue)[%G?] %Cgreen[%cr] %C(bold black)<%an>%Creset%C(yellow)%d %Creset %s%Creset' \
			--date=relative \
			-n 10

	echo "# ${reponame} created in ${pathPrefix}/${reponame}"
fi

if type code >/dev/null; then
	code -g ./cmd/cli-client/main.go "${pathPrefix}/${reponame}"
fi
```

## Assumptions

### It uses `git initial-commit`

I wrote about this recently, and it's my preferred way to get a new `git`
repo up and running.

You can read more about this in [the blog entry]({% post_url
/blog/2021-02-03-git-initial-commit %}).

If you really don't want this, you can probably just replace the line with:

```sh
git init
```

### It assumes you're releasing to github, as me

The module name is automatically written in a "github friendly" manner. For
example `flizz` becomes `module github.com/chizmw/go-flizz`

You can alter the prefix by setting the following in your shell:

```sh
export GITHUB_USERNAME="myusername"
```

### It assumes you're using `~/development`

By default `clone-into-dir` will use `~/development` as the root location for
all clone actions.

If you prefer to have your code somewhere else you can set a variable in your
shell:

```sh
export CLONEINTO_ROOT=/path/to/your/preference
```

This value was chosen to match can read more about this in [the
`clone-into-dir` post]({% post_url /blog/2021-02-12-new-golang-project %}).

## Source

Just in case the script moves on after the article is published,
[here's the source file][github-homebin-newgolangproject]

## In Action

When you run the script you will see something like this. Output truncated
for artistic brevity.

![the command in action](/assets/img/blog/2021-02-12-new-golang-project-in-action.png)

[github-homebin-newgolangproject]: https://github.com/chizmchizmwshellrcd-extras-chizcw/blob/extras/chizcw/home-bin/new-golang-project
