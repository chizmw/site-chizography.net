---
layout: post
title:  "Managing Shell Configuration"
author: Chisel
date:   2021-02-07 19:46:36 +0100
categories: [blog, tech]
tags: [shell, bash, zsh, config, configuration]
description: >
    Managing a `bash` or `zsh` configuration can be tricky or clunky,
    especially if you work on multiple different machines and want some
    level of consistency.

    This is one possible solution to the problem.
image:
  path:    /assets/img/blog/2021-02-07-managing-shell-configuration-underground-bunker.jpg
  srcset:
    1920w: /assets/img/blog/2021-02-07-managing-shell-configuration-underground-bunker.jpg
    960w:  /assets/img/blog/2021-02-07-managing-shell-configuration-underground-bunker@0,5x.jpg
    480w:  /assets/img/blog/2021-02-07-managing-shell-configuration-underground-bunker@0,25x.jpg
---

Managing a `bash` or `zsh` configuration can be tricky or clunky, especially
if you work on multiple different machines and want some level of
consistency.

This is one possible solution to the problem.

<!--more-->

* this unordered seed list will be replaced by the toc
{:toc}

## A Brief History

Longer ago than I care to remember I used to, uhm, "sync" my `bash` setup by
always making sure that I had "a copy somewhere" that I could copy from
machine to machine, and sometimes even keep them all synced up with the
updates.

In late 2010 I had a _better idea_ and wrote a small proof od concept that
was loosely based on runlevels and exectable bits being set or not.

For a number of years I was manually cloining my private repo (because
**Private Tokens**) and adding the same block to my `.bashrc` file:

~~~sh
cat >> ~/.bashrc <<EOF
# part of $HOME/.shellrc.d
if [ -f $HOME/.shellrc.d/source-relevant-files -a -x $HOME/.shellrc.d/source-relevant-files ]; then
    source $HOME/.shellrc.d/source-relevant-files
fi
EOF
~~~

Over time I added `dotfiles/` which I would softlink into appropriate places,
and later add `home-bin/` to be a placeholder for common scripts I like to
take with me.

I automated it and added some helpers to "link things to places" and pootled
along for .. well, longer than I should have.

In 2020 I realised that it was silly to use something called `bashrcd` to
manage a mixture of `bash` and `zsh` settings; I'd started my migration to
the latter and needed to manage both.

I decided that after almost 10 years it was time to make a proper tool.

## `shellrcd`

### Overview

I took my ideas, previous code, experience, and needs to start a new project.
Because I wasnted to be generic from the start, I opted for the imaginitively
hames `shellrcd`.

Due to my limited shell experience I only wrote a project that supported
`bash` and `zsh`, but hopefully in a manner that would be extensible for The
Next Great Shell.

### The Gist

The idea for the new project was to have a base repo that _anyone_ can use,
with support for personalised extensions, and some further support for
private repos (to keep those pesky personall access tokens)

* `shellrcd` - the top level project written and managed by yours truly
* `shellrcd-extras` - a (public) repo written and managed by yourself
* `shellrcd-private` - a (private) repo manages by yourself; this gets cloned as a `git submodule`

### Getting Started

One aim for the new project was to make it as easy as possible to get
started, as well as staying up to date with any changes pushed to the remote
repos.

Getting the most basic setup is as simple as:

~~~sh
# for the sensible, paranoid, people out there, the repo readme also has
# instructions on how to download and inspect the script before running
# anything
sh -c "$(curl -fsSL https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh)"
~~~

#### Creating A Test User

To provide a working example of the process I suggest testing with a demo user:

~~~sh
# run this and follow the prompts
sudo adduser --shell /bin/zsh shellbot
~~~

become the new user:

~~~sh
sudo su - shellbot
~~~

You'll see a message/warning. For now select `q`:

> (q)  Quit and do nothing.  The function will be run again next time.

We're planning on replacing everthing soon enough.

#### Perform A Basic Installation

Before you do anything make sure you have this, it will save you some extra work later on:

~~~sh
mkdir -p ~/bin
~~~

We really ought to update the script to create this on your behalf if it doesn't exist.
{:.note}

Running the installation command from earlier will perform the appropriate
magic and output something resembling the following:

~~~text
protomolecule% sh -c "$(curl -fsSL https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh)"
[shellrcd] /home/shellbot/.shellrc.d is not found. Downloading...
[shellrcd] ...done
[zsh] Looking for an existing zsh config...
[zsh] Creating /home/shellbot/.zshrc and adding shellrcd block...
[bash] Looking for an existing bash config...
[bash] Non-MacOS detected. Using .bashrc.
[bash] Adding shellrcd block to /home/shellbot/.bashrc...
[shellrcd] Found /home/shellbot/bin; installing shellrcd-update
           _             _    _                    _
          ( )           (_ ) (_ )                 ( )
      ___ | |__     __   | |  | |  _ __   ___    _| |
    /',__)|  _ `\ /'__`\ | |  | | ( '__)/'___) /'_` |
    \__, \| | | |(  ___/ | |  | | | |  ( (___ ( (_| |
    (____/(_) (_)`\____)(___)(___)(_)  `\____)`\__,_)
                                ....is now installed!

    Please look over /home/shellbot/.bashrc for any glaring errors.

    Check which scripts are active with:
        sh /home/shellbot/.shellrc.d/tools/list-active.sh

    Once happy, open a new shell or:
        source /home/shellbot/.bashrc
protomolecule%
~~~

I'm not 100% certain why it's talking about `/home/shellbot/.bashrc` in a
`zsh` session. I might have to go gug-hunting. It's only cosmetic, but
shouldn't really be doing that.
{:.note}


If you examine either `.bashrc` or `.zshrc` you'll see the manual block that
I mentioned at the start of this article:

~~~zsh
# file: ".zshrc"
#!/usr/bin/zsh

## added by shellrcd ##
if [ -f ~/.shellrc.d/source-relevant-files -a -x ~/.shellrc.d/source-relevant-files ]; then
    source ~/.shellrc.d/source-relevant-files
fi
## end of shellrcd block ##
~~~

Test it's working by logging out, then logging back in:

~~~sh
# stop being shellbot
exit

# become shellbot again
sudo su - shellbot
~~~

You'll see something like this:

~~~zsh
protomolecule% exit
❯ sudo su - shellbot
gpg-agent[25887]: directory '/home/shellbot/.gnupg' created
gpg-agent[25887]: directory '/home/shellbot/.gnupg/private-keys-v1.d' created
gpg-agent[25888]: gpg-agent (GnuPG) 2.2.4 started
protomolecule%
~~~

`shellrcd` does its best to leave existing installations untouched, so you
can safely run the installation command again:

~~~text
protomolecule% sh -c "$(curl -fsSL https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh)"
[shellrcd] /home/shellbot/.shellrc.d already exists. Leaving unchanged.
[zsh] Looking for an existing zsh config...
[zsh] shellrcd block already added to /home/shellbot/.zshrc. Nothing to do.
[bash] Looking for an existing bash config...
[bash] Non-MacOS detected. Using .bashrc.
[bash] shellrcd block already added to /home/shellbot/.bashrc. Nothing to do.
[shellrcd] Found /home/shellbot/bin; installing shellrcd-update
[shellrcd] /home/shellbot/bin/shellrcd-update already exists but is not a symbolic link
[shellrcd] … consider removing it and running this script again
           _             _    _                    _
          ( )           (_ ) (_ )                 ( )
      ___ | |__     __   | |  | |  _ __   ___    _| |
    /',__)|  _ `\ /'__`\ | |  | | ( '__)/'___) /'_` |
    \__, \| | | |(  ___/ | |  | | | |  ( (___ ( (_| |
    (____/(_) (_)`\____)(___)(___)(_)  `\____)`\__,_)
                                ....is now installed!

    Please look over /home/shellbot/.bashrc for any glaring errors.

    Check which scripts are active with:
        sh /home/shellbot/.shellrc.d/tools/list-active.sh

    Once happy, open a new shell or:
        source /home/shellbot/.bashrc
~~~

`shellrcd-update` is installed as a softlink, so clearly another bug to raise
for ourselves there.
{:.note}

### Extending `shellrcd`

The aim of `shellrcd` is to be as minimal as possible, and leave you to grow
your own suite of startup scripts.

For an example of the format preferred, take a look at the [_agnostic/
folder][agnostic-folder] in the base project.

It's good practice to have startup elements in smaller discrete chunks, so
that you can manage them in a more granular fashion.

#### Create A New Extras Respository

Create a new repository somewhere. We're using Github for this demo:

![new github repo](/assets/img/blog/2021-02-07-managing-shell-configuration-new-github-repo.png)


#### Update Your Local Project

To keep out of your way `shellrcd` initialises itself with a non-`origin` named remote:

~~~sh
protomolecule% git remote -v
shellrcd	git://github.com/chiselwright/shellrcd.git (fetch)
shellrcd	git://github.com/chiselwright/shellrcd.git (push)
~~~

leaving you free to add _your_ extras repository as `origin`:

~~~sh
# make sure you're in the right place for this to work
cd ~/.shellrc.d

# you'll need to replace the repo details for your use case
git remote add origin git@github.com:chiselwright/shellrcd-extras-shellbot.git

# you might need to generate an ssh keypair for your test user
#     ssh-keygen
# and add to your account in Github
git remote update origin
~~~

Not much happens, but we're now in a position for the next step:

~~~sh
git checkout -b extras/firstlast shellrcd/master
~~~

will give you some standard `git` output:

~~~text
Branch 'extras/firstlast' set up to track remote branch 'master' from 'shellrcd'.
Switched to a new branch 'extras/firstlast'
~~~

You're now ready to test that everything still works .. with no extras, but with the added repository ready to go:

~~~sh
shellrcd-update
~~~

will output something like this:

~~~text
[shellrcd] Switching back to 'master'…
Switched to branch 'master'
Your branch is up to date with 'shellrcd/master'.
[shellrcd] Pulling recent changes into master…
Already up to date.
Current branch master is up to date.
[shellrcd] Switching back to 'extras/firstlast'…
Switched to branch 'extras/firstlast'
Your branch is up to date with 'shellrcd/master'.
[shellrcd] Pulling recent changes into extras/firstlast…
Already up to date.
Current branch extras/firstlast is up to date.
[shellrcd] Rebasing master and extras/firstlast…
Current branch extras/firstlast is up to date.
           _             _    _                    _
          ( )           (_ ) (_ )                 ( )
      ___ | |__     __   | |  | |  _ __   ___    _| |
    /',__)|  _ `\ /'__`\ | |  | | ( '__)/'___) /'_` |
    \__, \| | | |(  ___/ | |  | | | |  ( (___ ( (_| |
    (____/(_) (_)`\____)(___)(___)(_)  `\____)`\__,_)
                                ....is up to date!

    You are running from:
        extras/firstlast

    Updates will activate in a new shell, or if you source your rcfile
~~~

`shellrcd` hasn't yet been tested with non-`master` default branches. It
might work through sheer luck, but be careful of you want to use something
different.
{:.note}

If this works, make sure to push it to the remote:

~~~sh
git push -u origin extras/firstlast
~~~

At this point you will have a personal repo that contains an exact copy of
`shellrcd` in the `extras/firstlast` branch.

#### Your First Customisation

You're free to do whatever you wish to extend the setup you have in place now
that you have your extras repo in place.

This is a simple example of your forst change, and verifying an update.

~~~sh
echo 'alias just-a-test="echo Just A Test"' > ~/.shellrc.d/_agnostic/alias.test
chmod 0755 ~/.shellrc.d/_agnostic/alias.test

cd ~/.shellrc.d/
git add _agnostic/alias.test
git commit -m 'Add _agnostic/alias.test'
~~~

Note - you only have the change locally. This is OK for now.

~~~sh
protomolecule% git log --oneline -n 2
cda1b7d (HEAD -> extras/firstlast) Add _agnostic/alias.test
4cd72d7 (shellrcd/master, shellrcd/HEAD, origin/extras/firstlast, master) Add setup_shellrcd_submodules to install.sh
~~~

Test an update:

~~~sh
shellrcd-update
~~~

The output will look very similar to the previous time we tested the update.

Test the new script would be picked up either by logging out and back in, or
taking the simpler route of resourcing your rcfile:

~~~sh
. ~/.zshrc
~~~

for example:

~~~sh
protomolecule% alias |grep test
protomolecule% . ~/.zshrc
protomolecule% alias |grep test
just-a-test='echo Just A Test'
~~~

#### A Shell Specific Customisation

Soemtimes, no matter how hard you try, some things just aren't shell agnostic enough to live in `_agnostic/`

If you end up in this situation, simple add your script(s) to `bash/` or
`zsh/`, make them executable, and they'll be included in the shell
initialisation.

The shell specific folders are processed **after** `_agnostic/`.

Let's create a quick addition to the `zsh/` folder now:

~~~sh
# create the new file
cat <<'EOF' >> ~/.shellrc.d/zsh/50.precmd.tmux
precmd() { if [ -n "$TMUX" ] ; then tmux rename-window "$(basename $PWD)"; fi; }
EOF

# make it executable
chmod 0755 ~/.shellrc.d/zsh/50.precmd.tmux 

# get it into git
cd ~/.shellrc.d/
git add zsh/50.precmd.tmux
git commit -m 'Add zsh/50.precmd.tmux'
# no need for fpush as there hasn't been any rebasing since we started
git push
~~~

### Redeploying

Clearly no one want to repeat all of those individual steps after the initial
time preparing the repos.


### Best Practices

#### if something doesn't exist, skip don't fail

Sometimes you'll want to run extra commands if _something_ is installed, or
you only want to create alises if a certain exectable is available.

A good pattern for this is with `type`:

~~~sh
if type "someCommand" >/dev/null; then
    # do some stuff
fi
~~~

This will extend your setup if you have something installed, and continue
merrily if it doesn't.

Here are a couple of examples:

~~~sh
# file: "_agnostic/20.alias.generate-password_aws"
if type "aws" >/dev/null; then
    # spits out a string, ready to use as a password
    # (no longer requires jq to do waht we can do with the command we already have)
    alias generate-password='aws secretsmanager get-random-password --exclude-punctuation --query "RandomPassword" --output text'
fi
~~~

or this one that will attempt to install for you:

~~~sh
# file: "_agnostic/98.glow-markdown"
# do things if NOT installed
if ! type "glow" >/dev/null; then
  # maybe we have brew
  if type "brew" >/dev/null; then
      echo "[Installing 'glow' with 'brew']"
      brew install charmbracelet/homebrew-tap/glow
  # maybe we have golang
  elif type go >/dev/null; then
      echo "[Installing 'glow' with 'go get']"
      go get github.com/charmbracelet/glow
  # ok, nothing, but we feel it's worth knowing about
  else
      echo "glow: can't locate 'brew' or 'go'; skipping installation"
  fi
fi

# if we find it's installed when we get this far, either because we already had
# it, or just installed it above, add an alias that defaults to using --pager
if type "glow" >/dev/null; then
    alias glow='glow --pager'
fi
~~~

#### always `--force-with-lease` when pushing changes after updates

Because you'll be rebasing your "local feature branch" from another branch,
you'll be bessing with your commit history.

This is fine, because it's only you working in the branch (I hope!)

This does mean you will need to _force push_ any changes you make if there have been upstream changes:

~~~sh
git push --force with lease
~~~

To make this simpler, set a global alias:

~~~sh
git config --global alias.fpush "push --force-with-lease"
~~~

and use:

~~~sh
git fpush
~~~

Read more about `--force-with-lease` in this [StackOverflow post][git-force-push-with-lease].
#### always `--rebase` when pulling changes

You'll get into a world of pain if you `git pull` from your remote without using the `--rebase` option.
Assuming a version of `git` >= `1.7.9`:

~~~sh
git config --global pull.rebase true
~~~

Of course you can avoid this in this project and simply run:

~~~sh
shellrdc-update
~~~

Rebasing by default is a generally good practice to use with any git
repositories. Read more in
["Please, oh please, use git pull --rebase"][article-git-rebase]

## Attributions

- <a href="https://www.freepik.com/free-photos-vectors/computer">Computer vector created by upklyak - www.freepik.com</a>


[agnostic-folder]: https://github.com/chiselwright/shellrcd/tree/master/_agnostic
[agnostic-folder-chisel]: https://github.com/chiselwright/shellrcd-extras-chizcw/tree/extras/chizcw/_agnostic
[article-git-rebase]: https://coderwall.com/p/7aymfa/please-oh-please-use-git-pull-rebase
[git-force-push-with-lease]: https://stackoverflow.com/a/52823955
