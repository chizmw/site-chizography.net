---
layout: post
title:  "Command history in the perl debugger"
date:   2019-09-06 02:03:04 +0100
author: Chisel
categories: [Tech]
tags: perl debugger repost
---
I’m always forgetting what pieces I need to make this happen, so I’m writing a note to my future self.

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

[post-2011]: http://blogs.perl.org/users/chisel/2013/01/command-history-in-the-perl-debugger.html
