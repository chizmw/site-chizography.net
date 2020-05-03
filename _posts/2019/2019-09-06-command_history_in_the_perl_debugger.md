---
layout: post
title:  "Command history in the perl debugger"
date:   2019-09-06 02:03:04 +0100
author: Chisel
categories: [Tech]
tags: perl debugger repost
image: /assets/posts/2019-09-06-command_history_in_the_perl_debugger/lugar-trabajo-programado.jpg
---

![]({{page.image}}){: class="imagedropshadow imagecenter" }

I’m always forgetting what pieces I need to make this happen, so I’m writing a note to my future self.

<!--more-->

### Ubuntu Packages

Install:

* libncurses-dev
* libreadline-dev

### Perl Packages

Install:

* Term::ReadLine::Gnu

Save a little time with puppet

Include these somewhere and run a puppet update:

```
class libncurses-dev {
    package { libncurses-dev: ensure => latest }
}

class libreadline-dev {
    package { libreadline-dev: ensure => latest }
}
```


### Save the history to a file
Add this to ~/.perldb

```
&parse_options("HistFile=$ENV{HOME}/.perldb.hist");
```

<small>(This is a repost of [a post made to blogs.perl.org in 2013][post-2013])</small>

## Attribution

Some images require attribution links as part of their terms:

- <a href="https://www.freepik.com/free-photos-vectors/banner">Banner vector created by roserodionova - www.freepik.com</a>

[post-2013]: http://blogs.perl.org/users/chisel/2013/01/command-history-in-the-perl-debugger.html
