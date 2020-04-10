---
layout: post
title:  "Configuring tmux"
date:   2020-04-10 02:03:04 +0000
author: Chisel
image:  /assets/posts/2020-04-10-tmux-restore-session/terminal-screengrab.png
categories: [Tech]
tags: tmux tech configuration
---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Introduction](#introduction)
- [Pre-requisites](#pre-requisites)
  - [tmux](#tmux)
  - [tpm](#tpm)
  - [Know your tmux prefix](#know-your-tmux-prefix)
- [.tmux.conf](#tmuxconf)
- [custom `tmux` configuration](#custom-tmux-configuration)
- [Troubleshooting](#troubleshooting)
  - [Confirming Continuum is 'active'](#confirming-continuum-is-active)
  - [Confirming a save interval has been set](#confirming-a-save-interval-has-been-set)
  - [Confirming the resurrection folder exists](#confirming-the-resurrection-folder-exists)
  - [Testing Session Restores](#testing-session-restores)
- [Further Reading](#further-reading)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![](/assets/posts/2020-04-10-tmux-restore-session/terminal-screengrab.png){: class="imagedropshadow imagecenter" }

## Introduction

Part of my working environment changed recently, causing me to investigate ways
to preserve a `tmux` session over a reboot.

I initially investigated a short script, which didn't pas muster for two
reasons:

1. it was manual to save and restore
2. I couldn't make it behave sesnsibly
3. it didn't restore running tasks (where possible)

A short detour via a Google search led me to the wonders of `tmux` plugins.

I'd been using a messy and klunky `tmux` configuration for so long this felt
like the perfect time to kill two birds with one stone.

I felt this would be useful at work, so initially wrote this as some
instructions to get them off the4 starting blocks. Annoyingly I couldn't quite
make things behave as expected, so after sinking more than a few hours of my
personal time into making this work properly, I decided to make a version of
the final instructions available on my own site, so I could share the fruits
of my labour with anyone.

## Pre-requisites

### tmux

Before you do anything at all, make sure you have installed a "recent" version of `tmux`.
This post was tested with `tmux 2.9a` and `tmux 3.0a` (check yours with
`tmux -V`).

### tpm

Also, make sure you have installed the [tmux plugin manager](https://github.com/tmux-plugins/tpm):

    # git should create intermediate directories for you
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

### Know your tmux prefix

If you aren't sure what you're configured to use (`^b` seems to be [the default](https://www.google.com/search?q=tmux+default+prefix&oq=tmux+default+prefix))

## .tmux.conf

```sh
cat > ~/.tmux.conf <<EOF
# make sure we include the main plugin
set -g @plugin 'tmux-plugins/tpm'

# DO NOT be tempted to set -g @plugin in included files
# It seems that there's a scoping bug if you try to do this
source-file ~/.tmux-personal.conf

# force a value for continuum-save-interval;
# seems to avoid a reported issue
set -g @continuum-save-interval '10'

# List of useful plugins
set -g @plugin "arcticicestudio/nord-tmux"
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Initialize TMUX plugin manager
# (keep this line at the very bottom of tmux.conf)
run -b '~/.tmux/plugins/tpm/tpm'
EOF
```

To avoid warnings, touch the file you included:

```sh
touch ~/.tmux-personal.conf
```

Make sure you aren't polluted by past config:

```sh
tmux kill-server
tmux
```

Fetch your plugins:

- `prefix`, `I`

You should see:

```sh
TMUX environment reloaded.
Done, press ENTER to continue.
```

Check you have the (four) expected plugins:

```sh
❯ ls -1 ~/.tmux/plugins
tmux-continuum/
tmux-resurrect/
tmux-sensible/
tpm/
```

You're now up-and-running with a `tmux` that will (self) restore after a reboot.
**NOTE:** the auto-backups are set to run every 15 minutes, so please wait at least that long before testing the resurrection does actually take place.

## custom `tmux` configuration

To separate the basic config, and your customisations, you might want to create personal configuration in a separate file to include:

```sh
cat > ~/.tmux-personal.conf <<'EOF'
# unbind default prefix and set it to ctrl-x
unbind C-b
set -g prefix C-x
bind C-x send-prefix

# switch between two latest windows
# http://superuser.com/a/429560
bind-key C-x last-window

# inherit the shell you were using when you
# started the server/session
set -g default-shell "${SHELL}"

# we aren't computers, start window numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# http://superuser.com/a/552493/635749
bind-key -n C-S-Left swap-window -t -1
bind-key -n C-S-Right swap-window -t +1

# reload without reaching for the shift key
bind-key r run-shell ' \
    tmux source-file ~/.tmux.conf > /dev/null; \
    tmux display-message "Sourced .tmux.conf!"'
EOF
```

## Troubleshooting

### Confirming Continuum is 'active'

You can check that the autosave plugin is 'activated' by checking for `continuum_save.sh` in the output from:

```sh
tmux show-options -g status-right
```

for example (using [`nord-tmux`](https://github.com/arcticicestudio/nord-tmux)):

```sh
❯ tmux show-options -g status-right
status-right "#(/Users/chisel/.tmux/plugins/tmux-continuum/scripts/continuum_save.sh)#{prefix_highlight}#[fg=brightblack,bg=black,nobold,noitalics,nounderscore]#[fg=white,bg=brightblack] %Y-%m-%d #[fg=white,bg=brightblack,nobold,noitalics,nounderscore]#[fg=white,bg=brightblack] %H:%M #[fg=cyan,bg=brightblack,nobold,noitalics,nounderscore]#[fg=black,bg=cyan,bold] #H "
```

### Confirming a save interval has been set

Check you have a save interval set:

```sh
❯ tmux show-option -g @continuum-save-interval
@continuum-save-interval 10
```

### Confirming the resurrection folder exists

Check the resurrection folder (doesn't always exist initially; wait a few minutes):

```sh
ls -lrth ~/.tmux/resurrect
```

Be patient, it seems to wait until "save interval: has passed before making the first autosave.

When it's up and running you should see something like:

```sh
❯ ls -lrth ~/.tmux/resurrect
total 8
-rw-r--r--  1 chisel  staff    90B 10 Apr 10:45 tmux_resurrect_20200410T104505.txt
lrwxr-xr-x  1 chisel  staff    34B 10 Apr 10:45 last@ -> tmux_resurrect_20200410T104505.txt
```

### Testing Session Restores

You can test the restore works by:

- opening a new window in tmux
- running `top`, and leaving it running
- return to first window
- wait ... wait .. wait ... until the next auto-backup
- `tmux kill-server`
- `tmux`
- wait a couple of seconds and your last saved session should be restored

![](/assets/posts/2020-04-10-tmux-restore-session/terminal-tmux.conf.png){: class="imagedropshadow imagecenter" }


## Further Reading

- [tmux plugin manager](https://github.com/tmux-plugins/tpm)
- [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible)
- [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- [nord-tmux](https://github.com/arcticicestudio/nord-tmux)
- [tmux manual page](http://man7.org/linux/man-pages/man1/tmux.1.html)
