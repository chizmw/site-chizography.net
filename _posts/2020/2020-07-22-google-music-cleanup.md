---
layout: post
title:  "Google Music Cleanup"
author: Chisel
categories: [Tech]
tags: perl music google cleanup
image: /assets/posts/2020-07-22-google-music-cleanup/simon-noh-0rmby-3OTeI-unsplash.jpg
date:   2020-07-22 02:03:04 +0000
---

{% include post-lead-image.md %}

Although [Google Music is on the way out][music-out] it's active for a few more
months, and if you're like me you might still have [Music
manager][music-manager] running, and downloading "updates" to your collection.

Unless it's just me that Google Music hates you'll discover that you collection
starts to fill up with `MyTrack (1).mp3` and friends.

Being lazy and technical, I have a short script to fix that.

<!--more-->

Apologies in advace, but `perl` is still my go-to language for quick scripts.

```perl
#!/usr/bin/env perl
# gm-fixer.pl
use strict;
use warnings;
use feature 'say';

use File::Find::Rule;

my @files;

my $dir         = $ARGV[0] || die "missing argument";
my $mv_files    = $ARGV[1] || 0;

if (! -d $dir) {
    die "$dir: not a directory";
}

my @dirs = File::Find::Rule->directory()->maxdepth(1)->mindepth(1)->in($dir);

foreach my $dir (sort @dirs) {
    #say "[INFO] checking $dir...";
    finder($dir);
}

sub finder {
    my $dir = shift;

    # find paren-copies
    @files = File::Find::Rule->file()
                                ->name( '*([0-9]).mp3' )
                                ->in( $dir );

    foreach my $f2 (sort @files) {
        my $f = $f2;
        $f =~ s{\([1-9]\)}{};
        if ($mv_files) {
            say "[INFO] moving: '$f2' -> '$f'";
            rename($f2, $f) || die "cannot rename: $f2";
        }
        else {
            say "[INFO] found: '$f2'";
        }
    }
}
```

Get a feel for the size of the problem:

```sh
perl gm-fixer.pl /path/to/root/music/folder
```

Rename offending files:
```sh
perl gm-fixer.pl /path/to/root/music/folder 1
```

## Attributions

- <span>Photo by <a href="https://unsplash.com/@simon_noh?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Simon Noh</a> on <a href="https://unsplash.com/images/things/music?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>


[music-out]:     https://www.forbes.com/sites/barrycollins/2020/05/13/google-play-music-is-dying-dont-let-it-take-your-mp3-collection-with-it/#218a1e8c45c2
[music-manager]: https://support.google.com/googleplaymusic/answer/1075570?hl=en-GB
