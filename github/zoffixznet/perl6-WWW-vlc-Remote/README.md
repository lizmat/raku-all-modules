[![Build Status](https://travis-ci.org/zoffixznet/perl6-WWW-vlc-Remote.svg)](https://travis-ci.org/zoffixznet/perl6-WWW-vlc-Remote)

# NAME

WWW::vlc::Remote — Control vlc media player via its Web interface

# TABLE OF CONTENTS

- [SYNOPSIS](#synopsis)
- [EXAMPLES](#examples)
- [DESCRIPTION](#description)
- [ENABLE THE REMOTE](#enable-the-remote)
- [`WWW::vlc::Remote` class](#wwwvlcremote-class)
    - [METHODS](#methods)
        - [`.new`](#new)
        - [`.empty`](#empty)
        - [`.enqueue`](#enqueue)
        - [`.enqueue-and-play`](#enqueue-and-play)
        - [`.delete`](#delete)
        - [`.playlist`](#playlist)
        - [`.play`](#play)
        - [`.seek`](#seek)
        - [`.status`](#status)
        - [`.stop`](#stop)
        - [`.toggle-random`](#toggle-random)
        - [`.toggle-loop`](#toggle-loop)
        - [`.toggle-repeat`](#toggle-repeat)
        - [`.toggle-fullscreen`](#toggle-fullscreen)
        - [`.toggle-service-discovery`](#toggle-service-discovery)
        - [`.volume`](#volume)
- [`WWW::vlc::Remote::Track` class](#wwwvlcremotetrack-class)
    - [ATTRIBUTES](#attributes)
        - [`$.vlc`](#vlc)
        - [`$.uri`](#uri)
        - [`$.name`](#name-1)
        - [`$.id`](#id)
        - [`$.id`](#id-1)
    - [METHODS](#methods-1)
        - [`.play`](#play-1)
        - [`.Str`](#str)
        - [`.gist`](#gist)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# SYNOPSIS

```perl6
use lib <lib>;
use WWW::vlc::Remote;

my $vlc := WWW::vlc::Remote.new;
say "Available songs are:";
.say for $vlc.playlist: :skip-meta;

my UInt:D $song := val prompt "\nEnter an ID of song to play: ";
with $vlc.playlist.first: *.id == $song {
    say "Playing $_";
    .play
}
else {
    say "Did not find any songs with ID `$song`";
}
```

# EXAMPLES

See [`examples/`](examples/) dir for some examples of module's use.

# DESCRIPTION

Provides programmatic interface to
[VLC Media player](https://www.videolan.org/vlc/index.html) using its
[Web remote interface](https://wiki.videolan.org/VLC_HTTP_requests/).

# ENABLE THE REMOTE

Open up your VLC player, go to `Tools` → `Preferences` → `"Show settings" (all)` (bottom left) → `Interface` → `Main Interfaces` and ensure `"Web"` is checked.

You can now use `--http-password` command line option to `vlc` to enable
its Web remote. The password is required. It might be possible to set it in
the preferences somewhere (`Main Interfaces` → `Lua` → `"Lua HTTP"` →
`Password` maybe), but I was not able to successfully find where.

Along with `--http-password` you can set `--http-port` to adjust which port
`vlc` will listen on (defaults to `8080`). See `vlc --help --advanced` for more
options.

# `WWW::vlc::Remote` class

## METHODS

### `.new`

```perl6
submethod BUILD (
    Str    :$pass = 'pass',
    Str:D  :$host = 'http://127.0.0.1',
    UInt:D :$port = 8080,
)
```

Constructs and returns a new `WWW::vlc::Remote` object. Takes three named
arguments, all optional: the password for the vlc Web interface (that's
the value you specified to `--http-password`), as well as the host and the port
vlc is listening on.

### `.empty`

```perl6
method empty(--> WWW::vlc::Remote:D)
```

Empty the playlist. Returns the invocant.

### `.enqueue`

```perl6
method enqueue(Str:D $url --> WWW::vlc::Remote:D)
```

Add a media item to the playlist. Returns the invocant. The `$url` can be
a URL to the file on the filesystem or to an online resource.

### `.enqueue-and-play`

```perl6
method enqueue-and-play(Str:D \url --> WWW::vlc::Remote:D)
```

Add a media item to the playlist and start playing it. Returns the invocant.
The `$url` can be a URL to the file on the filesystem or to an online resource.

### `.delete`


```perl6
multi method delete (WWW::vlc::Remote::Track:D $track --> WWW::vlc::Remote::Track:D)
multi method delete (UInt:D $id --> WWW::vlc::Remote::Track:D)
```

Delete a track off the playlist. Takes either a `WWW::vlc::Remote::Track`
instance (obtainable from `.playlist` method) or an `Int` numeric ID of the
playlist track to delete. Returns the invocant.

### `.playlist`

```perl6
method playlist(Bool :$skip-meta --> Seq:D)
```

Returns a `Seq` of `WWW::vlc::Remote::Track` objects representing the
currently loaded play list. Some of the potential items on the playlist
aren't tracks but could be folders or artwork. Those are known as "meta" files
and setting `:$skip-meta` to true will skip those items.

Some "meta" files, such as directories on the playlist may contain more playable
files, however they need to be expanded for `.playlist` to see them. You can
expand them by giving their IDs or `WWW::vlc::Remote::Track` objects to
`WWW::vlc::Remote.play` method (or calling `.play` on that
`WWW::vlc::Remote::Track` object directly)

*Note:* currently what is and isn't a "meta" file is decided by whether
duration is a positive number. I don't know if that causes flagging of some
playable type of media as meta files.

### `.play`

```perl6
multi method play (--> WWW::vlc::Remote::Track:D)
multi method play (WWW::vlc::Remote::Track:D $track --> WWW::vlc::Remote::Track:D)
multi method play (UInt:D $id --> WWW::vlc::Remote::Track:D)
```

Takes either a `WWW::vlc::Remote::Track` instance (obtainable from
`.playlist` method) or an `Int` numeric ID of the playlist track to play.
Causes vlc to immediately start playing that track. Returns the invocant.

Can be called without any arguments, in which case the currently active
playlist item will be played (e.g. can be used after using `.stop`).

### `.seek`

```perl6
method seek ($val where Str:D|Numeric:D = '0%' --> ::?CLASS:D)
```

Seeks the current track based on the given `$val`. Per
[vlc's wiki](https://wiki.videolan.org/VLC_HTTP_requests/):

```
 Allowed values are of the form:
   [+ or -][<int><H or h>:][<int><M or m or '>:][<int><nothing or S or s or ">]
   or [+ or -]<int>%
   (value between [ ] are optional, value between < > are mandatory)
 examples:
   1000 -> seek to the 1000th second
   +1H:2M -> seek 1 hour and 2 minutes forward
   -10% -> seek 10% back
```

Using too-large values (e.g. `+220%`) is perfectly acceptable.

### `.status`

```perl6
method status(--> DOM::Tiny:D)
```

Fetches the XML of a bunch of info of the current status and returns it as
[`DOM::Tiny` object](https://modules.perl6.org/repo/DOM::Tiny)

### `.stop`

```perl6
method stop(--> WWW::vlc::Remote::Track:D)
```

Causes vlc to stop playing. Returns the invocant.

### `.toggle-random`

```perl6
method toggle-random(--> WWW::vlc::Remote:D)
```

Toggles random playback. Returns the invocant.

### `.toggle-loop`

```perl6
method toggle-loop(--> WWW::vlc::Remote:D)
```

Toggles loop. Returns the invocant.

### `.toggle-repeat`

```perl6
method toggle-repeat(--> WWW::vlc::Remote:D)
```

Toggles repeat. Returns the invocant.

### `.toggle-fullscreen`

```perl6
method toggle-fullscreen(--> WWW::vlc::Remote:D)
```

Toggles fullscreen. Returns the invocant.

### `.toggle-service-discovery`

```perl6
method toggle-service-discovery(Str:D $val--> WWW::vlc::Remote:D)
```

Toggles service discovery. Returns the invocant.
The `$val` argument is the service, which per
[vlc's wiki](https://wiki.videolan.org/VLC_HTTP_requests/):

```
 Typical values are:
   sap
   shoutcast
   podcast
   hal
```

### `.volume`

```perl6
method volume($val where Str:D|Numeric:D --> ::?CLASS:D)
```

Sets the volume based on the `$val`. Per
[vlc's wiki](https://wiki.videolan.org/VLC_HTTP_requests/):

```
 Allowed values are of the form:
   +<int>, -<int>, <int> or <int>%
```

**Note:** during my testing, the `%` values did not work.

# `WWW::vlc::Remote::Track` class

This class isn't meant to be instantiatable directly and instead is returned
from by some `WWW::vlc::Remote` methods, such as `.playlist`.

## ATTRIBUTES

### `$.vlc`

```perl6
has WWW::vlc::Remote:D $.vlc
```

The `WWW::vlc::Remote` object that created this `WWW::vlc::Remote::Track`
object.

### `$.uri`

```perl6
has Str:D $.uri
```

The URI of this track.

### `$.name`

```perl6
has Str:D $.name
```

The name of this track.

### `$.id`

```perl6
has UInt:D $.id
```

The ID of this track. This is the ID desired by some `WWW::vlc::Remote`
methods, such as `.play`.

### `$.id`

```perl6
has Int:D $.duration
```

The duration of this track, in seconds. Can be zero or even negative if this
track isn't a proper playable item, such as a directory or artwork.

## METHODS

### `.play`

```perl6
method play(--> WWW::vlc::Remote:D)
```

Takes no arguments and causes vlc to play this track. The same as calling
`WWW::vlc::Remote.play` with the ID of this track. Returns the
`WWW::vlc::Remote` object that created this `WWW::vlc::Remote::Track` object.

### `.Str`

```perl6
method Str (--> Str:D)
```

Returns a string in the form of `"$id $name ($dur)"` where `$id` is the track's
`$.id`, `$name` is `$.name`, and `$dur` is a string in the form of `2m45s`
calculated from the track's `$.duration` (no hours, only minutes and seconds).
If `$.duration` is zero or negative, `$dur` is set to string `N/A`.

### `.gist`

```perl6
method gist (--> Str:D)
```

Calls `.Str` on the invocant and returns the result.

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-WWW-vlc-Remote

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-WWW-vlc-Remote/issues

#### AUTHOR

Zoffix Znet (https://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
