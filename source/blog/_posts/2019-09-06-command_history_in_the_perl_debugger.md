---
layout: post
title:  "Command history in the perl debugger"
date:   2019-09-06 02:03:04 +0100
author: Chisel
categories: [blog, tech]
tags: [perl, debugger, repost]
description: >
    If you're one of the rare people that prefers the `perl` debugger over
    `warn()` statements everywhere in your code you will benefit from a
    functioning command history in the debugger.
image:
  path:    /assets/img/blog/2019-09-06-command_history_in_the_perl_debugger-lugar-trabajo-programado.jpg
  srcset:
    1920w: /assets/img/blog/2019-09-06-command_history_in_the_perl_debugger-lugar-trabajo-programado.jpg
    960w:  /assets/img/blog/2019-09-06-command_history_in_the_perl_debugger-lugar-trabajo-programado@0,5x.jpg
    480w:  /assets/img/blog/2019-09-06-command_history_in_the_perl_debugger-lugar-trabajo-programado@0,25x.jpg
---

{% include read-estimate.md %}

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

~~~puppet
class libncurses-dev {
    package { libncurses-dev: ensure => latest }
}

class libreadline-dev {
    package { libreadline-dev: ensure => latest }
}
~~~


### Save the history to a file
Add this to ~/.perldb

~~~perl
# file: "~/.perldb"
&parse_options("HistFile=$ENV{HOME}/.perldb.hist");
~~~

<small>(This is a repost of [a post made to blogs.perl.org in 2013][post-2013])</small>
{:.faded}


## Attribution

Some images require attribution links as part of their terms:

- <a href="https://www.freepik.com/free-photos-vectors/banner">Banner vector created by roserodionova - www.freepik.com</a>

[post-2013]: http://blogs.perl.org/users/chisel/2013/01/command-history-in-the-perl-debugger.html
