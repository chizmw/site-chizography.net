---
layout: post
title:  "Quick way to grab and install a Plex server update"
author: Chisel
categories: [Tech]
tags: plex server update rpm quicktip tip
image: /assets/posts/plex-rpm-update/cinema-with-cashbox-counter-with-popcorn.jpg
---

{% include post-lead-image.md %}

If you run your own Plex media server you might see messages for server updates
(especially if you're running the beta).

Getting a bit bored of downloading, locating, updating .. all manually .. I
decided to write a quick script to simplify the process for me.

<!--more-->

## Assumptions

- You are running Plex Media Server on a box that is Debian based.
- You have a configuration that adds `$HOME/bin` to your path

It shouldn't be too hard to tweak this for other package types.

## Why?

Server updates are alway a long URL, which redirects to the actual download, and if you're viewing the update link on a machine that's not the actual server, you often end up downloading the package in the wrong place.

```
https://plex.tv/downloads/latest/5?channel=8&build=linux-x86_64&distro=debian&X-Plex-Token=sekritToken
```

## The Script

```
cat >$HOME/bin/grab-and-update <<'EOF'
#!/bin/bash
set -euo pipefail

if [ -z "$1" ]; then
    echo "Must pass URL of new version";
    exit;
fi

mkdir -p $HOME/plex-flow/deb-packages
cd $HOME/plex-flow/deb-packages

wget --quiet --show-progress --content-disposition "$1"

ls -1rt *.deb|tail -n1
sudo dpkg -i $(ls -1rt *.deb|tail -n1)
EOF
```

```
chmod 0700 $HOME/bin/grab-and-update
```

## Running The Script

Right-click and "Copy Address", then paste the URL in single-quotes:

```
grab-and-update 'theUrl'
```

## Attributions

- <a href="https://www.freepik.com/free-photos-vectors/food">Food vector created by upklyak - www.freepik.com</a>
