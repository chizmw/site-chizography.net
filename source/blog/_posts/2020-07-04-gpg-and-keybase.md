---
layout: post
title:  "GPG with Keybase"
date:   2020-07-04 02:03:04 +0000
author: Chisel
categories: [blog, tech]
description: >
      Managing GPG keys is one of those things that's far too easy to forget to keep
      on top of. Having Keybase as part of your toolset can save you from yourself.
tags: [gpg, keybase keybase.io, howto]
image:
  path:    /assets/img/blog/2020-07-04-gpg-and-keybase-abstract-secure-technology-background.jpg
  srcset:
    1920w: /assets/img/blog/2020-07-04-gpg-and-keybase-abstract-secure-technology-background.jpg
    960w:  /assets/img/blog/2020-07-04-gpg-and-keybase-abstract-secure-technology-background@0,5x.jpg
    480w:  /assets/img/blog/2020-07-04-gpg-and-keybase-abstract-secure-technology-background@0,25x.jpg
---

{% include read-estimate.md %}

Managing GPG keys is one of those things that's far too easy to forget to keep
on top of. Having Keybase as part of your toolset can save you from yourself.

<!--more-->

* this unordered seed list will be replaced by the toc
{:toc}

# Managing GPG keys with Keybase

The [recent acquisition of Keybase by Zoom][acquisition] might send some people
running.  If you're one of those people, save yourself a few minutes and skip
this one.

## Prerequisites

### Keybase

[Download, and install Keybase][install-keybase]. Explore, get yourself mildly
comfortable with them.

The desktop apps are quite nice to have, but steps in this document require
that you have installed the [command-line client][cli-keybase].

### GPG

You'll need to [install a `gpg`][install-gpg] command-line client otherwise you won't get far
at all with the whole process.

## Importing Existing Key(s)

This is what you will want to do when you're on a new machine to import your
existing key(s) from Keybase.
_If you're starting from scratch, skip this and jump to the key creation
instructions._

This is essentially an export from Keybase piped into a gpg import:

You only need `-q keyId` if you have multiple keys.

```sh
keybase pgp export -q keyId |gpg --import
```

and

```sh
keybase pgp export -q keyID --secret |gpg --import --allow-secret-key-import
```

For example:

```sh
❯ keybase pgp export -q 24C5369983FB95FB |gpg --import
gpg: key 24C5369983FB95FB: "Blog Demo <blog.demo@chizography.net>" 1 new signature
gpg: Total number processed: 1
gpg:         new signatures: 1

❯ keybase pgp export -q 24C5369983FB95FB --secret |gpg --import --allow-secret-key-import
gpg: key 24C5369983FB95FB: "Blog Demo <blog.demo@chizography.net>" not changed
gpg: key 24C5369983FB95FB: secret key imported
gpg: Total number processed: 1
gpg:              unchanged: 1
gpg:       secret keys read: 1
gpg:  secret keys unchanged: 1
```

## Starting From Scratch

### Create New GPG Key

If this is your first time with GPG you'll need a key to work with.

```sh
gpg --gen-key
```

Just follow the prompts and you'll be fine. Slighty edited output for brevity:

```
❯ gpg --gen-key

GnuPG needs to construct a user ID to identify your key.

Real name: Blog Demo
Email address: blog.demo@chizography.net
You selected this USER-ID:
    "Blog Demo <blog.demo@chizography.net>"

Change (N)ame, (E)mail, or (O)kay/(Q)uit? o

gpg: key 24C5369983FB95FB marked as ultimately trusted
gpg: directory '/path/to/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/path/to/.gnupg/openpgp-revocs.d/E06DDC6B8B12BE971C82CD9924C5369983FB95FB.rev'
public and secret key created and signed.

pub   rsa2048 2020-07-03 [SC] [expires: 2022-07-03]
      E06DDC6B8B12BE971C82CD9924C5369983FB95FB
uid                      Blog Demo <blog.demo@chizography.net>
sub   rsa2048 2020-07-03 [E] [expires: 2022-07-03]
```

### Verify Key Exists Locally

You should take a moment to verify that you really have created a new gpg key.

First check public keys:

```sh
❯ gpg --list-keys
pub   rsa2048 2020-07-03 [SC] [expires: 2022-07-03]
      E06DDC6B8B12BE971C82CD9924C5369983FB95FB
uid           [ultimate] Blog Demo <blog.demo@chizography.net>
sub   rsa2048 2020-07-03 [E] [expires: 2022-07-03]
```

Next make sure you have your private key:

```sh
❯ gpg --list-secret-keys --keyid-format LONG

/path/to/.gnupg/pubring.kbx
--------------------------------
sec   rsa2048/24C5369983FB95FB 2020-07-03 [SC] [expires: 2022-07-03]
      E06DDC6B8B12BE971C82CD9924C5369983FB95FB
uid                 [ultimate] Blog Demo <blog.demo@chizography.net>
ssb   rsa2048/FB17BDCFFE854BB4 2020-07-03 [E] [expires: 2022-07-03]
```

### Push To Keybase

If you work on more than one laptop, or virtual server, or plan to ever replace
any of your hardware, it's really convenient to have your keys (safely) stored
in Keybase's secure filesystem:

You should use the _fingerprint_ for your new key. Thag's the really long
string if you're not sure.

```sh
gpg --armor --export-secret-keys E06DDC6B8B12BE971C82CD9924C5369983FB95FB |keybase pgp import
```

You'll see something like this:

```
▶ INFO Generated new PGP key:
▶ INFO   user: Blog Demo <blog.demo@chizography.net>
▶ INFO   2048-bit RSA key, ID 24C5369983FB95FB, created 2020-07-03
```

Confirm Keybase knows about this key now with `keybase pgp list`:

```sh
❯ keybase pgp list
Keybase Key ID:  010151db5deebfcb219fa761c1ae5876b51520fe3c748fffb834139201362d5224ff0a
PGP Fingerprint: e06ddc6b8b12be971c82cd9924c5369983fb95fb
PGP Identities:
   Blog Demo <blog.demo@chizography.net>
```

# Troubleshooting

## Failed to restart keybase.service: Unit keybase.service not found.

I saw this when I was working on a headless server.

```
export KEYBASE_SYSTEMD=0
```

seems to resolve this.

# Attributions

- <a href="https://www.freepik.com/free-photos-vectors/technology">Technology vector created by stories - www.freepik.com</a>

[acquisition]: https://www.cnbc.com/2020/05/07/zoom-buys-keybase-in-first-deal-as-part-of-plan-to-fix-security.html
[cli-keybase]: https://github.com/keybase/client/blob/master/go/README.md
[install-gpg]: https://gnupg.org/
[install-keybase]: https://keybase.io/download
