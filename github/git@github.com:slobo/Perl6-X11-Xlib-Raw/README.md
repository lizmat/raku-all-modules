# X11::Xlib::Raw [![Build Status](https://travis-ci.org/slobo/Perl6-X11-Xlib-Raw.svg?branch=master)](https://travis-ci.org/slobo/Perl6-X11-Xlib-Raw)

A `NativeCall` interface to `Xlib`.

Only a subset needed to cover the examples is currently implemented.

# Examples

Filename     | Description
-------------|----------------------------------------
[01-basic](examples/01-basic.pl6) | Replicates the [Xlib Example from Wikipedia](https://en.wikipedia.org/wiki/Xlib#Example)
[02-x-window-list](examples/02-x-window-list.pl6) | Replicates the [x-window-list from no-wm project](https://github.com/patrickhaller/no-wm/blob/master/x-window-list.c)
[03-basic-wm](examples/03-basic-wm.pl6) (WIP) | Replicates the [basic_wm project](https://github.com/jichu4n/basic_wm). Currently we only draw borders around existing windows
