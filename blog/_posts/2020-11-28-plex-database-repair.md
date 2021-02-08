---
layout: post
title:  "Plex Database Repair on an NVIDIA SHIELD Pro"
author: Chisel
categories: [blog, tech]
description: >
  Sometimes you'll find you have a corrupt database on your media server.
  This article should get you back up and running.
tags: [plex, nvidia, shield, database, repair, sqlite, howto]
date:   2020-11-28 02:03:04 +0000
image:
  path:    /assets/img/blog/2020-11-28-plex-database-repair-benjamin-lehman-GNyjCePVRs8-unsplash.jpg
  srcset:
    1920w: /assets/img/blog/2020-11-28-plex-database-repair-benjamin-lehman-GNyjCePVRs8-unsplash.jpg
    960w:  /assets/img/blog/2020-11-28-plex-database-repair-benjamin-lehman-GNyjCePVRs8-unsplash@0,5x.jpg
    480w:  /assets/img/blog/2020-11-28-plex-database-repair-benjamin-lehman-GNyjCePVRs8-unsplash@0,25x.jpg
---

{% include read-estimate.md %}

This article relies heavily on [the plex support
document][plex-support-corrupt] for repairing a corrupt database. It includes
some extra steps that I've found useful for performing the process on my
NVIDIA SHIELD Pro device.

<!--more-->

* this unordered seed list will be replaced by the toc
{:toc}

## Prerequisites

### sqlite3

You must have `sqlite3` installed to perform the integrity check and repair
process.

If you're on a Mac, I strongly recommend [homebrew][mac-homebrew] and it's as
simple as:

~~~sh
brew install sqlite
~~~

### Library on external storage

You **must** have configured your Plex Media Server to use an external USB
drive as the location for the library data.

If you haven't already done this, there are [instructions
online][plex-library-on-usb] and I've had no problems with a [SanDisk Ultra
Fit 128 GB][amazon-sandisk-usb]

After a 48-hour period in early 2021 where I would return to the media server and discover that ther USB was flagged as corrupt I replaced the USB stick mentioned above with a standard [SanDisk Ultra 128 GB][amazon-usb-sandisk-ultra]
{:.note title="Update"}

## Shutdown Cleanly

I'm paranoid, and want to do as much as possible to reduce the risk of adding
more problems to the mix.

### Stop the media server

- open Plex on your <i class="fad fa-gamepad-alt"></i> SHIELD Pro
- open Settings from the left menubar
- navigate down to the "Plex Media Server" section
- select the first icon ("Running")
- change Status to OFF

### Unmount USB device

- return to the <i class="fad fa-gamepad-alt"></i> SHIELD Pro home screen
- open the <i class="fad fa-gamepad-alt"></i> SHIELD Pro's settings (cog icon in the top-right corner)
- open Device Preferences
- open Storage
- select your USB device and click to open the menu for it
- "Eject" the device
  - please don't Eject and Format!

You can now remove the device and perform the repair process.
As part of my paranoia, and desire to change as little as possible, I make a
mental note which USB port I am removing the device from.

## Repair The Database

If you're in any doubt how to perform this please read the
[full instructions][plex-support-corrupt]

### Plug The USB Device In To A Computer or Laptop

Once it's mounted, open a terminal window and verify where the device was
mounted:

~~~sh
mount
~~~

Change to that directory:

~~~sh
# this will vary based on your system and USB stick
cd /Volumes/SanDisk128G
~~~

From there we'll use a little bit of magic to take us to the Databases
directory:

~~~sh
cd "$(find . -type d -name 'Plex Media Server' -prune)/Plug-in Support/Databases"
~~~

Confirm you're in the correct location. You should see something that looks
like this:

~~~sh
❯ ls -1
com.plexapp.plugins.library.blobs.db
com.plexapp.plugins.library.blobs.db-shm
com.plexapp.plugins.library.blobs.db-wal
com.plexapp.plugins.library.db
~~~

#### Check For Corruption

~~~sh
# backup the library
cp com.plexapp.plugins.library.db com.plexapp.plugins.library.db.original

# drop a specific index
sqlite3 com.plexapp.plugins.library.db "DROP index 'index_title_sort_naturalsort'"

# delete a specific schema migration
sqlite3 com.plexapp.plugins.library.db "DELETE from schema_migrations where version='20180501000000'"

# perform the integrity check
sqlite3 com.plexapp.plugins.library.db "PRAGMA integrity_check"
~~~

On my currently corrupted database the final command outputs the following:
~~~sh
❯ sqlite3 com.plexapp.plugins.library.db "PRAGMA integrity_check"
*** in database main ***
Page 22634: btreeInitPage() returns error code 11
Page 22635: btreeInitPage() returns error code 11
Page 22636: btreeInitPage() returns error code 11
Error: database disk image is malformed
~~~

### Run The Repair

The official page repeats the "backup, drop index, delete schema migration"
steps. I'm relying on you working through this page in order, so there's no
need to do this twice.

~~~sh
# dump the current database
sqlite3 com.plexapp.plugins.library.db .dump > dump.sql

# remove the corrupt database (we made a copy!)
rm com.plexapp.plugins.library.db

# create a new version of the database from the dump
sqlite3 com.plexapp.plugins.library.db < dump.sql
~~~

Because we're working on USB storage we can skip the `chown` step in the
official documents.

### Post Repair Steps

~~~sh
# keep the original (corrupt) database safe for now
mv *.original $HOME

# keep our dumped schema
mv dump.sql $HOME

# remove some unnecessary files
rm -fv com.plexapp.plugins.library.db-shm com.plexapp.plugins.library.db-wal
~~~
You should now eject/unmount your USB device.

Before you attempt this, you should leave the current working directory:

~~~sh
# I'm being explicit about the location here but 'cd' on its own works
cd $HOME
~~~

**Eject your USB device**

## Getting Plex Up And Running Again

### Insert USB

- wake up your <i class="fad fa-gamepad-alt"></i> SHIELD Pro
- return to the home screen
- plug the USB device back into your <i class="fad fa-gamepad-alt"></i> SHIELD Pro, preferable the same port you used previously.

After a few seconds you should see a message indicating that the device has
been detected, and it is quite likely that is will scan the device before
making it available to use.

**This is the time when you need to be patient!**

Check the status of your device by returning to the Storage settings:

- return to the <i class="fad fa-gamepad-alt"></i> SHIELD Pro home screen
- open the <i class="fad fa-gamepad-alt"></i> SHIELD Pro's settings (cog icon in the top-right corner)
- open Device Preferences
- open Storage

Once you see the device listed normally, it should be safe to restart your media server.

### Start the media server

- open Plex on your <i class="fad fa-gamepad-alt"></i> SHIELD Pro device

You might find that you're taken straight to the settings area you were
looking at earlier. If that's not the case follow the same steps as before to
get to them:

- open Settings from the left menubar
- navigate down to the "Plex Media Server" section

Now you're ready to start the media server:

- select the first icon ("Stopped")
- change Status to ON

This is another step where actions take longer to complete than you might
expect. Be patient. Don't panic.

While writing this guide the interface showed "Stopped" for at least a
minute, then finally updated to "Running".

## Rejoice!

Click "back" to go from the Plex settings to your library screen, and you
should see the library contents you know and love.

Mine is showing the "Continue Watching" (waiting for me to finish Season 3 of
[Battlestar Galactica][bsg-imdb] so I can return to the last ten minutes of
[Razor][bsg-razor]. Why? I'm rewatching using the [Ultimate Viewing
Order][bsg-viewing-order]) and "On Deck" that I had prior to the repair
process.

## Attributions

- <span>Photo by <a href="https://unsplash.com/@benjaminlehman?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">benjamin lehman</a> on <a href="https://unsplash.com/s/photos/database?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>

[amazon-sandisk-usb]:       https://smile.amazon.co.uk/gp/product/B07855LJ99/
[amazon-usb-sandisk-ultra]: https://smile.amazon.co.uk/gp/product/B00P8XQPY4/
[bsg-imdb]:                 https://www.imdb.com/title/tt0407362/
[bsg-razor]:                https://www.imdb.com/title/tt0991178/
[bsg-viewing-order]:        https://thunderpeel2001.blogspot.com/2010/02/battlestar-galactica-viewing-order.html
[mac-homebrew]:             https://brew.sh/
[plex-library-on-usb]:      https://support.plex.tv/articles/moving-server-data-storage-location-on-nvidia-shield/
[plex-support-corrupt]:     https://support.plex.tv/articles/201100678-repair-a-corrupt-database/
