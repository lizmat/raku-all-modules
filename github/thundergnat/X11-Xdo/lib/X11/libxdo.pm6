unit module X11::libxdo:ver<0.1.0>:auth<github:thundergnat>;

use NativeCall;
use X11::Xlib::Raw;

=begin pod

=head1 NAME

X11::Xdo

Version: 0.1.0

Perl 6 bindings to the L<libxdo X11 automation library|https://github.com/jordansissel/xdotool>.

Note: This is a WORK IN PROGRESS. The tests are under construction and many of
them may not work on your computer. Several functions are not yet implemented,
but a large core group is.

Many of the test files do not actally run tests that can be checked for
correctness. (Many of the object move & resize tests for example.)
Rather, they attempt to perform an action and fail/pass based on if the attempt
does or doesn't produce an error.

Not all libxdo functions are supported by every window manager. In general,
mouse info & move and window info, move, & resize routines seem to be well
supported, others... not so much.

=head1 SYNOPSIS

    use X11::libxdo;

    my $xdo = Xdo.new;

    say 'Version: ', $xdo.version;

    say 'Active window id: ', my $active = $xdo.get-active-window;

    say 'Active window title: ', $xdo.get-window-name($active);

    say "Pause for a bit...";
    sleep 4; # pause for a bit

    loop {
        my ($x, $y, $window-id, $screen) = $xdo.get-mouse-info;
        my $name = (try $xdo.get-window-name($window-id) if $window-id)
           // 'No name set';

        my $line = "Mouse location: $x, $y, Window under mouse - ID: " ~
           $window-id ~ ', Name: ' ~ $name ~ ", Screen #: $screen";

        print "\e[H\e[JMove mouse around screen; move to top to exit.\n", $line;

        # exit if pointer moved to top of screen
        say '' and last if $y < 1;

        # update periodically.
        sleep .05;
    }


=head1 DESCRIPTION

Perl 6 bindings to the [libxdo X11 automation library](https://github.com/jordansissel/xdotool).

Requires that libxdo-dev library is installed and accessible.

=begin table
Platform 	          |  Install Method
======================================================
Debian and Ubuntu     |  [sudo] apt-get install libxdo-dev
FreeBSD               |  [sudo] pkg install libxdo-dev
Fedora                |  [sudo] dnf install libxdo-dev
OSX                   |  [sudo] brew install libxdo-dev
OpenSUSE              |  [sudo] zypper install libxdo-dev
Source Code on GitHub |  https://github.com/jordansissel/xdotool/releases
=end table


Many (most?) of the xdo methods take a window ID # in their parameters. This is
an integer ID# and MUST be passed as an unsigned Int. In general, to act on the
currently active window, set the window ID to 0 or just leave blank.

Note that many of the methods will require a small delay for them to finish
before moving on to the next, especially when performing several actions in a
row. Either do a short sleep or a .activate-window($window-ID) to give the
action time to complete before moving on to the next action.

There are several broad categories of methods available.

=item Misc
=item Mouse
=item Window
=item Keystrokes
=item Desktop

=head2 Miscellaneous

=begin code
.version()
=end code

Get the library version.

Takes no parameters.

Returns the version string of the current libxdo library.

--
=begin code
.get_symbol_map()
=end code

Get modifier symbol pairs.

Takes no parameters.

Returns an array of modifier symbol pairs.

--
=begin code
.search(%query)
=end code

Reimplementation of the libxdo search function to give greater flexibility under
Perl 6.

May seach for a name, class, ID or pid or any combination, against a string / regex.

    .search( :name(), :class(), :ID(), :pid() )

Search for an open window where the title contains the exact string 'libxdo':

     .search( :name('libxdo') )

Search for an open window where the title contains 'Perl' case insensitvely:

     .search( :name(rx:i['perl']) )

Returns a hash { :name(), :class(), :ID(), :pid() } pairs of the first match
found for one of the search parameters.

if you need more granularity or control over the search, use get-windows to get
a hash of all of the visible windows and search through them manually.

--
=begin code
.get-windows()
=end code

Takes no parameters.

Returns a hoh of all of the visible windows keyed on the ID number with value
of a hash of { :name(), :class(), :ID(), :pid() } pairs.


=head2 Mouse

=begin code
.move-mouse( $x, $y, $screen )
=end code

Move the mouse to a specific location.

Takes three parameters:

=item int $x:      the target X coordinate on the screen in pixels.
=item int $y:      the target Y coordinate on the screen in pixels.
=item int $screen  the screen (number) you want to move on.

Returns 0 on success !0 on failure.

--
=begin code
.move-mouse-relative( $delta-x, $delta-y )
=end code

Move the mouse relative to it's current position.

Takes two parameters:

=item int $delta-x:    the distance in pixels to move on the X axis.
=item int $delta-y:    the distance in pixels to move on the Y axis.

Returns 0 on success !0 on failure.

--
=begin code
.move-mouse-relative-to-window( $x, $y, $window )
=end code

Move the mouse to a specific location relative to the top-left corner
of a window.

Takes three parameters:

=item int $x:      the target X coordinate on the screen in pixels.
=item int $y:      the target Y coordinate on the screen in pixels.
=item Window $window: ID of the window.

Returns 0 on success !0 on failure.

--
=begin code
.get-mouse-location()
=end code

Get the current mouse location (coordinates and screen ID number).

Takes no parameters;

Returns three integers:

=item int $x:       the x coordinate of the mouse pointer.
=item int $y:       the y coordinate of the mouse pointer.
=item int $screen:  the index number of the screen the mouse pointer is located on.

--
=begin code
.get-mouse-info()
=end code

Get all mouse location-related data.

Takes no parameters;

Returns four integers:

=item int $x:       the x coordinate of the mouse pointer.
=item int $y:       the y coordinate of the mouse pointer.
=item Window $window:  the ID number of the window the mouse pointer is located on.
=item int $screen:  the index number of the screen the mouse pointer is located on.

--
=begin code
.wait-for-mouse-to-move-from( $origin-x, $origin-y )
=end code

Wait for the mouse to move from a location. This function will block
until the condition has been satisfied.

Takes two integer parameters:

=item int $origin-x: the X position you expect the mouse to move from.
=item int $origin-y: the Y position you expect the mouse to move from.

Returns nothing.

--
=begin code
.wait-for-mouse-to-move-to( $dest-x, $dest-y )
=end code

Wait for the mouse to move to a location. This function will block
until the condition has been satisfied.

Takes two integer parameters:

=item int $dest-x: the X position you expect the mouse to move to.
=item int $dest-y: the Y position you expect the mouse to move to.

Returns nothing.

--
=begin code
.mouse-button-down( $window, $button )
=end code

Send a mouse press (aka mouse down) for a given button at the current mouse
location.

Takes two parameters:

=item Window $window:  The ID# of the window receiving the event. 0 for the current window.
=item int $button:  The mouse button. Generally, 1 is left, 2 is middle, 3 is right, 4 is wheel up, 5 is wheel down.

Returns nothing.

--
=begin code
.mouse-button-up( $window, $button )
=end code

Send a mouse release (aka mouse up) for a given button at the current mouse
location.

Takes two parameters:

=item Window $window:  The ID# of the window receiving the event. 0 for the current window.
=item int $button:  The mouse button. Generally, 1 is left, 2 is middle, 3 is right, 4 is wheel up, 5 is wheel down.

Returns nothing.

--
=begin code
.mouse-button-click( $window, $button )
=end code

Send a click for a specific mouse button at the current mouse location.

Takes two parameters:

=item Window $window:  The ID# of the window receiving the event. 0 for the current window.
=item int $button:  The mouse button. Generally, 1 is left, 2 is middle, 3 is right, 4 is wheel up, 5 is wheel down.

Returns nothing.

--
=begin code
.mouse-button-multiple( $window, $button, $repeat = 2, $delay? )
=end code

Send a one or more clicks of a specific mouse button at the current mouse
location.

Takes three parameters:

=item Window $window:  The ID# of the window receiving the event. 0 for the current window.
=item int $button:  The mouse button. Generally, 1 is left, 2 is middle, 3 is right, 4 is wheel up, 5 is wheel down.
=item int $repeat:  (optional, defaults to 2) number of times to click the button.
=item int $delay:   (optional, defaults to 8000) useconds delay between clicks. 8000 is a reasonable default.

Returns nothing.

--
=begin code
.get-window-under-mouse()
=end code

Get the window the mouse is currently over

Takes no parameters.

Returns the ID of the topmost window under the mouse.


=head2 Window

=begin code
.get-active-window()
=end code

Get the currently-active window. Requires your window manager to support this.

Takes no parameters.

Returns one integer:

=item $screen:  Window ID of active window.

--
=begin code
.select-window-with-mouse()
=end code

Get a window ID by clicking on it. This function blocks until a selection
 is made.

Takes no parameters.

Returns one integer:

=item $screen:  Window ID of active window.

--
=begin code
.get-window-location( $window?, $scrn? )
=end code

Get a window's location.

Takes two optional parameters:

=item Window $window: Optional parameter window ID. If none supplied, uses active window ID.
=item int $screen: Optional parameter screen ID. If none supplied, uses active screen ID.

Returns three integers:

=item $x:       x coordinate of top left corner of window.
=item $y:       y coordinate of top left corner of window.
=item $screen   index of screen the window is located on.

--
=begin code
.get-window-size( $window? )
=end code

Get a window's size.

Takes one optional parameter:

=item Window $window: Optional parameter window ID. If none supplied, uses active window ID.

Returns two integers:

=item int $width     the width of the queried window in pixels.
=item int $height    the height of the queried window in pixels.

--
=begin code
.get-window-geometry( $window? )
=end code

Get a windows geometry string.

Takes one optional parameter:

=item Window $window: Optional parameter window ID. If none supplied, uses active window ID.

Returns standard geometry string

=item Str $geometry  "{$width}x{$height}+{$x}+{$y}" format

400x200+250+450  means a 400 pixel wide by 200 pixel high window with the top
left corner at 250 x position 450 y position.

--
=begin code
.get-window-name( $window? )
=end code

Get a window's name, if any.

Takes one optional parameter:

=item Window $window: Optional parameter window ID. If none supplied, uses active window ID.

Returns one string:

=item Str $name   Name of the queried window.

--
=begin code
.get-window-pid( $window )
=end code

Get the PID or the process owning a window. Not all applications support this.
It looks at the _NET_WM_PID property of the window.

Takes one  parameter:

=item Window $window: Window ID.

Returns one integer:

=item int $pid   process id, or 0 if no pid found.

--
=begin code
.set-window-size( $window, $width, $height, $flags? = 0 )
=end code

Set the window size.

Takes four parameters:

=item Window $window:   the ID of the window to resize.
=item int $width:    the new desired width.
=item int $height:   the new desired height

=begin item
int $flags:    Optional, if 0, use pixels for units. Otherwise the units will
be relative to the window size hints.
=end item

HINTS:

=item 0 size window in pixels
=item 1 size X dimension relative to character block width
=item 2 size Y dimension relative to character block height
=item 3 size both dimensions relative to character block size

Returns 0 on success !0 on failure.

--
=begin code
.focus-window( $window )
=end code

Set the focus on a window.

Takes one  parameter:

=item Window $window:  ID of window to focus on.

Returns 0 on success !0 on failure.

--
=begin code
.get-focused-window( )
=end code

Get the ID of the window currently having focus.

Takes no parameters:

Returns one parameter:

=item Window $window:  ID of window currently having focus.


--
=begin code
.activate-window( $window )
=end code

Activate a window. This is generally a better choice than .focus_window
for a variety of reasons, but it requires window manager support.

=item If the window is on another desktop, that desktop is switched to.
=item It moves the window forward rather than simply focusing it

Takes one  parameter:

=item Window $window: Window ID.

Returns 0 on success !0 on failure.

--
=begin code
.raise-window( $window )
=end code

Raise a window to the top of the window stack. This is also sometimes
termed as bringing the window forward.

Takes one parameter:

=item Window $window: Window ID.

Returns 0 on success !0 on failure.

--
=begin code
.minimize( $window )
=end code

Minimize a window.

Takes one parameter:

=item Window $window: Window ID.

Returns 0 on success !0 on failure.

--
=begin code
.map-window( $window )
=end code

Map a window. This mostly means to make the window visible if it is
not currently mapped.

Takes one parameter:

=item Window $window: Window ID.

Returns 0 on success !0 on failure.

--
=begin code
.unmap-window( $window )
=end code

Unmap a window. This means to make the window invisible and possibly remove it
from the task bar on some WMs.

Takes one parameter:

=item Window $window: Window ID.

Returns 0 on success !0 on failure.

--
=begin code
.move-window( $window )
=end code

Move a window to a specific location.

The top left corner of the window will be moved to the x,y coordinate.

Takes three parameters:

=item Window $window: Window ID of the window to move.
=item int $x :     the X coordinate to move to.
=item int $y:      the Y coordinate to move to.

Returns 0 on success !0 on failure.

--
=begin code
.wait_for_window_active( $window )
=end code

Wait for a window to be active or not active.
Requires your window manager to support this.
Uses _NET_ACTIVE_WINDOW from the EWMH spec.

Takes one parameter:

=item Window $window: Window ID. If none supplied, uses active window ID.

Returns 0 on success !0 on failure.

--
=begin code
.close-window( $window )
=end code

TODO not working under Cinnamon?

Close a window without trying to kill the client.

Takes one  parameter:

=item Window $window: Optional parameter window ID. If none supplied, uses active window ID.

Returns 0 on success !0 on failure.

--
=begin code
.kill-window( $window )
=end code

TODO not working under Cinnamon?

Kill a window and the client owning it.

Takes one  parameter:

=item Window $window: Optional parameter window ID. If none supplied, uses active window ID.

Returns 0 on success !0 on failure.

--
=begin code
.override-redirect( $window, $value )
=end code

TODO not working under Cinnamon?

Set the override_redirect value for a window. This generally means
whether or not a window manager will manage this window.

Takes two parameters:

=item Window $window: Optional parameter window ID. If none supplied, uses active window ID.
=item int $value:  If you set it to 1, the window manager will usually not draw borders on the window, etc. If you set it to 0, the window manager will see it like a normal application window.

Returns 0 on success !0 on failure.

--
=begin code
.wait-for-window-map-state( $window, $state )
=end code

Wait for a window to have a specific map state.

State possibilities:

=item 0 IsUnmapped - window is not displayed.
=item 1 IsViewable - window is mapped and shown (though may be clipped by windows on top of it)
=item 2 IsUnviewable - window is mapped but a parent window is unmapped.

Takes two parameters:

=item Window $window: Window ID, the window you want to wait for.
=item int map_state:  the state to wait for.


--
=begin code
.set-window-state( $window, $action, $property)
=end code

Change window state

Takes three parameters:

=item Window $window: Window ID, the window you want to act on.
=item ulong  $action: the _NET_WM_STATE action
=item str  $property: the property to change

--
=begin code
    ACTIONS:
    _NET_WM_STATE_REMOVE: 0 -  remove/unset property
    _NET_WM_STATE_ADD:    1 -  add/set property
    _NET_WM_STATE_TOGGLE: 2 -  toggle property

    SOME POSSIBLE PROPERTIES:
    _NET_WM_STATE_MAXIMIZED_VERT
    _NET_WM_STATE_MAXIMIZED_HORZ
    _NET_WM_STATE_SHADED
    _NET_WM_STATE_HIDDEN
    _NET_WM_STATE_FULLSCREEN
    _NET_WM_STATE_ABOVE
    _NET_WM_STATE_BELOW
=end code

Retuns 0 on sucess, !0 on failure



=head2 Keystrokes

=begin code
.type( $window, $string, $delay? )
=end code

Type a string to the specified window.

If you want to send a specific key or key sequence, such as "alt+l", you
want instead send-sequence(...).

Not well supported under many window managers or by many applications
unfortunately. Somewhat of a crapshoot as to which applications pay attention to
this function. Web browsers tend to; (Firefox and Chrome tested), many other
applications do not. Need to try it to see if it will work in your situation.

Takes three parameters:

=item int    $window: The window you want to send keystrokes to or 0 for the current window.
=item string $string: The string to type, like "Hello world!"
=item int    $delay:  Optional delay between keystrokes in microseconds. 12000 is a decent choice if you don't have other plans.

Returns 0 on success !0 on failure.

--
=begin code
.send-sequence( $window, $string, $delay? )
=end code

This allows you to send keysequences by symbol name. Any combination
of X11 KeySym names separated by '+' are valid. Single KeySym names
are valid, too.

Examples:  "l"   "semicolon"  "alt+Return"  "Alt_L+Tab"

Takes three parameters:

=item int    $window: The window you want to send keystrokes to or 0 for the current window.
=item string $string: The string keysequence to send.
=item int    $delay:  Optional delay between keystrokes in microseconds. 12000 is a decent choice if you don't have other plans.

Returns 0 on success !0 on failure.

--
=begin code
.send-key-press( $window, $string, $delay? )
=end code

Send key press (down) events for the given key sequence.

See send-sequence

Takes three parameters:

=item int    $window: The window you want to send keystrokes to or 0 for the current window.
=item string $string: The string keysequence to send.
=item int    $delay:  Optional delay between key down events in microseconds.

Returns 0 on success !0 on failure.

--
=begin code
.send-key-release( $window, $string, $delay? )
=end code

Send key release (up) events for the given key sequence.

See send-sequence

Takes three parameters:

=item int    $window: The window you want to send keystrokes to or 0 for the current window.
=item string $string: The string keysequence to send.
=item int    $delay:  Optional delay between key down events in microseconds.

Returns 0 on success !0 on failure.

=end pod

#`[ TODO - need to figure out proper calling conventions.
Send a series of keystrokes.

window:   The window to send events to or CURRENTWINDOW
keys:     The array of charcodemap_t entities to send.
nkeys:    The length of the keys parameter
pressed:  1 for key press, 0 for key release.
modifier: Pointer to integer to record the modifiers activated by
          the keys being pressed. If NULL, we don't save the modifiers.
delay:     The delay between keystrokes in microseconds.

method send-keysequence-list($window = 0, Carray @keys, int $pressed, int, $modifier, int64 $delay = 12000) {
    sub xdo_send_keysequence_window_list_do(int64, int64, Carray, int, int, int64) returns int32 is native('xdo') { * };
    xdo_send_keysequence_window_list_do(self.id, @keys, +@keys, $pressed, $modifier, $delay)
}
]

=begin pod

=head2 Desktop

=begin code
.get-desktop-dimensions( $screen? )
=end code

Query the viewport (your display) dimensions

If Xinerama is active and supported, that api internally is used.
If Xinerama is disabled, will report the root window's dimensions
for the given screen.

Takes one parameter:

=item int $screen: Optional parameter screen index. If none supplied, uses default 0.

Returns three integers:

=item $x:       x dimension of the desktop window.
=item $y:       y dimension of the desktop window.
=item $screen   index of screen for which the dimensions are reported.


--
=begin code
.set-number-of-desktops($number)
=end code

Set the number of desktops. Uses _NET_NUMBER_OF_DESKTOPS of the EWMH spec.

Takes one parameter:

=item $ndesktops: the new number of desktops to set.

Returns 0 on success, !0 on failure


--
=begin code
.get-number-of-desktops()
=end code

Get the current number of desktops. Uses _NET_NUMBER_OF_DESKTOPS of the EWMH spec.

Takes no parameters:

Returns one integer:

=item $number: the current number of desktops (workspaces).

--
=begin code
.set-current-desktop($number)
=end code

Switch to another desktop. Uses _NET_CURRENT_DESKTOP of the EWMH spec.

Takes one parameter:

=item int $number The desktop number to switch to.


--
=begin code
.get-current-desktop()
=end code

Get the current desktop. Uses _NET_CURRENT_DESKTOP of the EWMH spec.

Takes no parmeters:

Returns one integer:

=item int $number The index number of the current desktop (workspace).


--
=begin code
.move-window-to-desktop($window, $number)
=end code

Move a window to another desktop. Uses _NET_WM_DESKTOP of the EWMH spec.

Takes two parameters:

=item Window $window:  ID of the window to move
=item int $desktop: the desktop destination for the window

Returns 0 on success, !0 on failure

--
=begin code
.get-desktop-for-window($window)
=end code

Get the desktop a window is on. Uses _NET_WM_DESKTOP of the EWMH spec.

If your desktop does not support _NET_WM_DESKTOP ruturns Nil.

Takes one parameter:

=item Window $window:  ID of the window to query.

Returns one integer:

=item int $desktop: the desktop where the window is located.

--
=begin code
.get-desktop-viewport()
=end code

Get the position of the current viewport.

This is only relevant if your window manager supports _NET_DESKTOP_VIEWPORT

Takes no parameters:

Returns two values:

=item int $x: the X value of the top left corner of the viewport.
=item int $y: the Y value of the top left corner of the viewport.

--
=begin code
.set-desktop-viewport($x, $y)
=end code

Set the position of the current viewport.

This is only relevant if your window manager supports _NET_DESKTOP_VIEWPORT

Takes two parameters:

=item int $x: the X value of the top left corner of the viewport.
=item int $y: the Y value of the top left corner of the viewport.


=head1 AUTHOR

2018 Steve Schulze aka thundergnat

This package is free software and is provided "as is" without express or implied
warranty.  You can redistribute it and/or modify it under the same terms as Perl
itself.

=head1 LICENSE

Licensed under The Artistic 2.0; see LICENSE.


=end pod

#===============================================================================

use NativeCall;

constant XDO          := Pointer;
constant Screen-index := int8;

class Xdo is export {
    has XDO $.id is rw;

    submethod BUILD {
        sub xdo_new(Str) returns XDO is native('xdo') { * }
        self.id = xdo_new('');
    }

    #`[ Return a string representing the version of this library.]
    method version() {
        sub xdo_version() returns Str is encoded('utf8') is native('xdo') { * }
        xdo_version()
    }

    #`[
    Move the mouse to a specific location.

    Takes three parameters:
      x:          the target X coordinate on the screen in pixels.
      y:          the target Y coordinate on the screen in pixels.
      screen ID:  the screen (number) you want to move on.
    ]
    method move-mouse (int32 $x, int32 $y is copy, Screen-index $screen is copy) {
        sub xdo_move_mouse(XDO, int32, int32, Screen-index) returns int32 is native('xdo') { * };
        ($, $, $screen ) = self.get-mouse-location unless $screen;
        xdo_move_mouse(self.id, $x, $y, $screen +& 15);
    }

    #`[
    Move the mouse to a specific location relative to the top-left corner
    of a window.

    Takes three parameters:
      window-ID:  ID of the window.
      x:          the target X coordinate on the screen in pixels.
      y:          the target Y coordinate on the screen in pixels.

    ]
    method move-mouse-relative-to-window ( Window $window, int32 $x, int32 $y ){
        sub xdo_move_mouse_relative_to_window(XDO, Window, int32, int32) returns int32 is native('xdo') { * };
        xdo_move_mouse_relative_to_window(self.id, $window, $x, $y)
    }


    #`[
    Move the mouse relative to it's current position.

    Takes two parameters:
      x:    the distance in pixels to move on the X axis.
      y:    the distance in pixels to move on the Y axis.
    ]
    method move-mouse-relative ( int32 $x, int32 $y ){
        sub xdo_move_mouse_relative(XDO, int32, int32) returns int32 is native('xdo') { * };
        xdo_move_mouse_relative(self.id, $x, $y)
    }

    #`[
    Send a mouse press (aka mouse down) for a given button at the current mouse
    location.

    Takes two parameters:
      window-ID:  The window receiving the event. 0 for the current window.
      button:     The mouse button. Generally, 1 is left, 2 is middle, 3 is
                   right, 4 is wheel up, 5 is wheel down.
    ]
    method mouse-button-down (Window $window = 0, int32 $button = 1) {
        sub xdo_mouse_down(XDO, Window, int32) returns int32 is native('xdo') { * };
        xdo_mouse_down(self.id, $window, $button)
    }

    #`[
    Send a mouse release (aka mouse up) for a given button at the current mouse
    location.

    window-ID:  The window receiving the event. 0 for the current window.
    button:     The mouse button. Generally, 1 is left, 2 is middle, 3 is
                right, 4 is wheel up, 5 is wheel down.
    ]
    method mouse-button-up (Window $window = 0, int32 $button = 1) {
        sub xdo_mouse_up(XDO, Window, int32) returns int32 is native('xdo') { * };
        xdo_mouse_up(self.id, $window, $button)
    }

    #`[
    Send a click for a specific mouse button at the current mouse location.

    window-ID:  The window receiving the event. 0 for the current window.
    button:     The mouse button. Generally, 1 is left, 2 is middle, 3 is
                right, 4 is wheel up, 5 is wheel down.
    ]
    method mouse-button-click (Window $window = 0, int32 $button = 1) {
        sub xdo_click_window(XDO, Window, int32) returns int32 is native('xdo') { * };
        xdo_click_window(self.id, $window, $button)
    }

    #`[
    Send a one or more clicks for a specific mouse button at the current mouse
    location.

    window-ID:  The window receiving the event. 0 for the current window.
    button:     The mouse button. Generally, 1 is left, 2 is middle, 3 is
                right, 4 is wheel up, 5 is wheel down.

    delay:      useconds delay between clicks. 8000 is a reasonable default.
    ]
    method mouse-button-multiple (Window $window = 0, int32 $button = 1, int32 $repeat = 2, int32 $delay = 8000) {
        sub xdo_mouse_multiple(XDO, Window, int32, int32, uint32) returns int32 is native('xdo') { * };
        xdo_mouse_multiple(self.id, $window, $button, $repeat, $delay)
    }

    #`[
    Get the current mouse location (coordinates and screen ID number).
    ]
    method get-mouse-location () {
        sub xdo_get_mouse_location(XDO, int32 is rw, int32 is rw, Screen-index is rw) returns int32 is native('xdo') { * };
        my int32 ($x, $y);
        my Screen-index $screen;
        my $error = xdo_get_mouse_location(self.id, $x, $y, $screen);
        $x, $y, $screen +& 15
    }

    #`[
    Get all mouse location-related data.

    Returns four integers: $x, $y, $window-ID, $screen-ID.
    ]
    method get-mouse-info () {
        sub xdo_get_mouse_location2(XDO, int32 is rw, int32 is rw, Screen-index is rw, Window is rw) returns int32 is native('xdo') { * };
        my int32 ($x, $y);
        my Screen-index $screen;
        my Window $window;
        my $error = xdo_get_mouse_location2(self.id, $x, $y, $screen, $window);
        $x, $y, $window, $screen +& 15
    }

    #`[
    Wait for the mouse to move from a location. This function will block
    until the condition has been satisfied.

    origin-x: the X position you expect the mouse to move from
    origin-y: the Y position you expect the mouse to move from
    ]
    method wait-for-mouse-to-move-from (int32 $origin-x, int32 $origin-y) {
        sub xdo_wait_for_mouse_move_from(XDO, int32, int32) returns int32 is native('xdo') { * };
        xdo_wait_for_mouse_move_from(self.id, $origin-x, $origin-y);
    }

    #`[
    Wait for the mouse to move to a location. This function will block
    until the condition has been satisfied.

    dest_x: the X position you expect the mouse to move to
    dest_y: the Y position you expect the mouse to move to
    ]
    method wait-for-mouse-to-move-to (int32 $dest-x, int32 $dest-y) {
        sub xdo_wait_for_mouse_move_to(XDO, int32, int32) returns int32 is native('xdo') { * };
        xdo_wait_for_mouse_move_to(self.id, $dest-x, $dest-y);
    }


   #`[
    Type a string to the specified window.

    If you want to send a specific key or key sequence, such as "alt+l", you
    want instead send-sequence(...).

    window: The window you want to send keystrokes to or CURRENTWINDOW
    string: The string to type, like "Hello world!"
    delay:  The delay between keystrokes in microseconds. 12000 is a decent
            choice if you don't have other plans.
    ]
    method type (Window $window, str $text = '', int32 $delay = 12000) {
        sub xdo_enter_text_window(XDO, Window, str, int32) returns int32 is native('xdo') { * };
        xdo_enter_text_window(self.id, $window, $text, $delay)
    }

    #`[
    This allows you to send keysequences by symbol name. Any combination
    of X11 KeySym names separated by '+' are valid. Single KeySym names
    are valid, too.

    Examples:
      "l"
      "semicolon"
      "alt+Return"
      "Alt_L+Tab"

    If you want to type a string, such as "Hello world." you want to instead
    use xdo_enter_text_window.

    window:      The window you want to send the keysequence to or
                   CURRENTWINDOW
    keysequence: The string keysequence to send.
    delay        The delay between keystrokes in microseconds.
    ]
    method send-sequence (Window $window = 0, str $keysequence = '', int32 $delay = 12000) {
        sub xdo_send_keysequence_window(XDO, Window, str, int32) returns int32 is native('xdo') { * };
        xdo_send_keysequence_window(self.id, $window, $keysequence, $delay)
    }

    #`[
    Send key release (up) events for the given key sequence.

    See send-sequence
    ]
    method send-key-release (Window $window = 0, str $keysequence = '', int32 $delay = 12000) {
        sub xdo_send_keysequence_window_up(XDO, Window, str, int32) returns int32 is native('xdo') { * };
        xdo_send_keysequence_window_up(self.id, $window, $keysequence, $delay)
    }

    #`[
    Send key press (down) events for the given key sequence.

    See send-sequence
    ]
    method send-key-press (Window $window = 0, str $keysequence = '', int32 $delay = 12000) {
        sub xdo_send_keysequence_window_down(XDO, int64, str, int32) returns int32 is native('xdo') { * };
        xdo_send_keysequence_window_down(self.id, Window, $keysequence, $delay)
    }

    #`[
    Send a series of keystrokes.

    window:   The window to send events to or CURRENTWINDOW
    keys:     The array of charcodemap_t entities to send.
    nkeys:    The length of the keys parameter
    pressed:  1 for key press, 0 for key release.
    modifier: Pointer to integer to record the modifiers activated by
              the keys being pressed. If NULL, we don't save the modifiers.
    delay:     The delay between keystrokes in microseconds.

    method send-keysequence-list($window = 0, Carray @keys, int $pressed, int, $modifier, int64 $delay = 12000) {
        sub xdo_send_keysequence_window_list_do(int64, int64, Carray, int, int, int64) returns int32 is native('xdo') { * };
        xdo_send_keysequence_window_list_do(self.id, @keys, +@keys, $pressed, $modifier, $delay)
    }
    ]

    #`[
    Get the window the mouse is currently over
    Returns the ID of the topmost window under the mouse.
    ]
    method get-window-under-mouse () {
        my Window $window;
        sub xdo_get_window_at_mouse(XDO, Window is rw) returns int32 is native('xdo') { * };
        xdo_get_window_at_mouse(self.id, $window);
        $window
    }

    #`[
    Get a window's location.
    Optional argument window ID. If none supplied, uses active window ID.
    Optional argument screen ID. If none supplied, uses active screen ID.
    Returns three integers: $x, $y, $screen-ID.
    ]
    method get-window-location (Window $window? is copy, Screen-index $screen? is copy ) {
        my int32 ($x, $y);
        $screen = 0 unless $screen;
        sub xdo_get_window_location(XDO, Window, int32 is rw, int32 is rw, Screen-index is rw) is native('xdo') { * };
        $window = self.get-active-window unless $window;
        xdo_get_window_location( self.id, $window, $x, $y, $screen );
        $x, $y, $screen +& 15
    }

    #`[
    Get a window's size.
    Optional argument window ID. If none supplied, uses active window ID.
    Returns two integers: width, height.
    ]
    method get-window-size (Window $window? is copy) {
        my int32 ($width, $height);
        sub xdo_get_window_size(XDO, Window, int32 is rw, int32 is rw) is native('xdo') { * };
        $window = self.get-active-window unless $window;
        xdo_get_window_size(self.id, $window, $width, $height);
        $width, $height;
    }

    #`[
    Get window geometry.
    Optional argument window ID. If none supplied, uses active window ID.
    Returns standard geometry strings
    ]
    method get-window-geometry (Window $window? is copy) {
        $window = self.get-active-window unless $window;
        my ($x, $y) = self.get-window-location($window);
        my ($width, $height) = self.get-window-size($window);
        "{$width}x{$height}+{$x}+{$y} "
    }

    #`[
    Change the window size.

      param window: the window to resize
      param w: the new desired width
      param h: the new desired height
      param flags: if 0, use pixels for units. If SIZE_USEHINTS, then
         the units will be relative to the window size hints.
    ]
    method set-window-size (Window $window, int32 $width, int32 $height, int32 $flags? = 0) {
        sub xdo_set_window_size(XDO, Window, int32, int32, int32) returns int32 is native('xdo') { * };
        xdo_set_window_size( self.id, $window, $width, $height, $flags );
    }

    #`[
    Get the currently-active window.
    Requires your window manager to support this.

    Returns ID of active window.
    ]
    method get-active-window () {
        my Window $window;
        sub xdo_get_active_window(XDO, Window is rw) returns int32 is native('xdo') { * };
        xdo_get_active_window(self.id, $window);
        $window;
    }

    #`[
    Get a window ID by clicking on it. This function blocks until a selection
     is made.

    Returns Window ID of the selected window.
    ]
    method select-window-with-mouse () {
        my Window $window;
        sub xdo_select_window_with_click(XDO, Window is rw) returns int32 is native('xdo') { * };
        my $error = xdo_select_window_with_click(self.id, $window);
        $window;
    }

    #`[
    Get a window's name, if any.
    ]
    method get-window-name (Window $window? is copy) {
        sub xdo_get_window_name(XDO, Window, Pointer is rw, int32 is rw, int32 is rw ) returns int32 is native('xdo') { * };
        $window = self.get-active-window unless $window;
        my $name = Pointer[Str].new;
        my int ($name-length, $name-type);
        xdo_get_window_name( self.id, $window, $name, $name-length, $name-type );
        $name.deref;
    }

    #`[
    Get the PID owning a window. Not all applications support this.
    It looks at the _NET_WM_PID property of the window.
    Returns the process id or 0 if no pid found.
    ]
    method get-window-pid (Window $window) {
        sub xdo_get_pid_window(XDO, Window) returns int32 is native('xdo') { * };
        xdo_get_pid_window( self.id, $window )
    }

    #`[ # TODO not working under Cinnamon?
    Kill a window and the client owning it.
    ]
    method kill-window (Window $window) {
        sub xdo_kill_window(XDO, Window) returns int32 is native('xdo') { * };
        xdo_kill_window( self.id, $window )
    }

    #`[ # TODO not working under Cinnamon?
    Close a window without trying to kill the client.
    ]
    method close-window (Window $window) {
        sub xdo_close_window(XDO, Window) returns int32 is native('xdo') { * };
        xdo_close_window( self.id, $window )
    }

    #`[
    Focus a window.
    ]
    method focus-window (Window $window) {
        sub xdo_focus_window(XDO, Window is rw) returns int32 is native('xdo') { * };
        xdo_focus_window( self.id, $window )
    }

    #`[
    Get the window currently having focus.

       param window_ret Pointer to a window where the currently-focused window
       ID will be stored.
    ]
    method get-focused-window () {
        my Window $window;
        sub xdo_get_focused_window_sane(XDO, Window) returns int32 is native('xdo') { * };
        xdo_get_focused_window_sane( self.id, $window );
        $window
    }


    #`[
    Activate a window. This is generally a better choice than xdo_focus_window
    for a variety of reasons, but it requires window manager support:
       - If the window is on another desktop, that desktop is switched to.
       - It moves the window forward rather than simply focusing it

    Requires your window manager to support this.
    Uses _NET_ACTIVE_WINDOW from the EWMH spec.
    ]
    method activate-window (Window $window) {
        sub xdo_activate_window(XDO, Window) returns int32 is native('xdo') { * };
        xdo_activate_window( self.id, $window );
    }

    #`[
    Raise a window to the top of the window stack. This is also sometimes
    termed as bringing the window forward.
    ]
    method raise-window (Window $window) {
        sub xdo_raise_window(XDO, Window) returns int32 is native('xdo') { * };
        xdo_raise_window( self.id, $window )
    }

    #`[
    Wait for a window to be active or not active.
    Requires your window manager to support this.
    Uses _NET_ACTIVE_WINDOW from the EWMH spec.

      param window: the window to wait on
      param active: If 1, wait for active. If 0, wait for inactive.
    ]
    method wait_for_window_active (Window $window, int32 $active) {
        sub xdo_wait_for_window_active(XDO, Window, int32) returns int32 is native('xdo') { * };
        xdo_wait_for_window_active( self.id, $window, $active );
    }


    #`[
    Wait for a window to have a specific map state.

     State possibilities:
       IsUnmapped - window is not displayed.
       IsViewable - window is mapped and shown (though may be clipped by windows
         on top of it)
       IsUnviewable - window is mapped but a parent window is unmapped.

      param window-id:  the window you want to wait for.
      param map_state:  the state to wait for.
     ]
    method wait-for-window-map-state(Window $window, int32 $state) {
        sub xdo_wait_for_window_map_state(XDO, Window, int32) returns int32 is native('xdo') { * };
        xdo_wait_for_window_map_state(self.id, $window, $state);
    }

    #`[
    Change window state

      param: $action -  the _NET_WM_STATE action
    ]
    method set-window-state(Window $window, ulong $action, str $property) {
        sub xdo_window_state(XDO, Window, ulong, str ) returns int32 is native('xdo') { * };
        xdo_window_state(self.id, $window, $action, $property)
    }

    #`[ # TODO not working under Cinnamon?
    Set the override_redirect value for a window. This generally means
    whether or not a window manager will manage this window.

    If you set it to 1, the window manager will usually not draw borders on the
    window, etc. If you set it to 0, the window manager will see it like a
    normal application window.
    ]
    method override-redirect (Window $window, int32 $value) {
        sub xdo_set_window_override_redirect(XDO, Window, int32 ) returns int32 is native('xdo') { * };
        xdo_set_window_override_redirect(self.id, $window, $value)
    }



    #`[
    Minimize a window.
    ]
    method minimize (Window $window) {
        sub xdo_minimize_window(XDO, Window) returns int32 is native('xdo') { * };
        xdo_minimize_window(self.id, $window)
    }

    #`[
    Map a window. This mostly means to make the window visible if it is
    not currently mapped.

    @param wid the window to map.
    ]
    method map-window (Window $window) {
        sub xdo_map_window(XDO, Window) returns int32 is native('xdo') { * };
        xdo_map_window(self.id, $window)
    }

    #`[
    Unmap a window

    @param wid the window to unmap
    ]
    method unmap-window (Window $window) {
        sub xdo_unmap_window(XDO, Window) returns int32 is native('xdo') { * };
        xdo_unmap_window(self.id, $window)
    }

    #`[
    Move a window to a specific location.

    The top left corner of the window will be moved to the x,y coordinate.

      param window the window to move
      param x the X coordinate to move to.
      param y the Y coordinate to move to.
    ]
    method move-window (Window $window, int32 $x, int32 $y) {
        sub xdo_move_window(XDO, Window, int32, int32) returns int32 is native('xdo') { * };
        xdo_move_window(self.id, $window, $x, $y)
    }

    method get_symbol_map () {
        [
          'alt'    => 'Alt_L',
          'ctrl'    => 'Control_L',
          'control' => 'Control_L',
          'meta'    => 'Meta_L',
          'super'   => 'Super_L',
          'shift'   => 'Shift_L',
          Nil       => Nil
        ]
    }

    #`[
     Query the viewport (your display) dimensions

      If Xinerama is active and supported, that api internally is used.
      If Xineram is disabled, we will report the root window's dimensions
      for the given screen.
    ]
    method get-desktop-dimensions (Screen-index $screen? is copy) {
        my uint32 ($width, $height);
        $screen //= 0;
        sub xdo_get_viewport_dimensions(XDO, uint32 is rw, uint32 is rw, Screen-index) returns int32 is native('xdo') { * };
        xdo_get_viewport_dimensions(self.id, $width, $height, $screen);
        $width, $height, $screen +& 15;
    }

    #`[
    Set the number of desktops. Uses _NET_NUMBER_OF_DESKTOPS of the EWMH spec.

      param ndesktops the new number of desktops to set.
    ]
    method set-number-of-desktops (long $number) {
        sub xdo_set_number_of_desktops(XDO, long) returns int32 is native('xdo') { * };
        xdo_set_number_of_desktops(self.id, $number)
    }

    #`[
    Get the current number of desktops. Uses _NET_NUMBER_OF_DESKTOPS of the EWMH spec.

      param ndesktops pointer to long where the current number of desktops is
    ]
    method get-number-of-desktops () {
        my $number := CArray[long].new;
        $number[0] = -2;
        sub xdo_get_number_of_desktops(XDO, CArray) returns int32 is native('xdo') { * };
        xdo_get_number_of_desktops(self.id, $number);
        $number[0]
    }


    #`[
    Switch to another desktop. Uses _NET_CURRENT_DESKTOP of the EWMH spec.

      param desktop The desktop number to switch to.
    ]
    method set-current-desktop (long $number) {
        sub xdo_set_current_desktop(XDO, long) returns int32 is native('xdo') { * };
        xdo_set_current_desktop(self.id, $number)
    }


   #`[
    Get the current desktop. Uses _NET_CURRENT_DESKTOP of the EWMH spec.

      param desktop pointer to long where the current desktop number is stored.
   ]
   method get-current-desktop () {
       my $number := CArray[long].new;
       $number[0] = -2;
       sub xdo_get_current_desktop(XDO, CArray) returns int32 is native('xdo') { * };
       xdo_get_current_desktop(self.id, $number);
       $number[0]
   }


   #`[
   Move a window to another desktop. Uses _NET_WM_DESKTOP of the EWMH spec.

     param wid the window to move
     param desktop the desktop destination for the window
   ]
   method move-window-to-desktop (Window $window, long $number) {
       sub xdo_set_desktop_for_window(XDO, Window, long) returns int32 is native('xdo') { * };
       xdo_set_desktop_for_window(self.id, $window, $number)
   }

    #`[
    Get the desktop a window is on. Uses _NET_WM_DESKTOP of the EWMH spec.

    If your desktop does not support _NET_WM_DESKTOP, then '*desktop' remains
    unmodified.

     param wid the window to query
     param desktop pointer to long where the desktop of the window is stored
    ]
    method get-desktop-for-window (Window $window) {
        my $number := CArray[long].new;
        $number[0] = -2;
        sub xdo_get_desktop_for_window(XDO, Window, CArray) returns int32 is native('xdo') { * };
        xdo_get_desktop_for_window(self.id, $window, $number);
        $number[0]
    }

    #`[
    Get the position of the current viewport.

    This is only relevant if your window manager supports _NET_DESKTOP_VIEWPORT
    ]
    method get-desktop-viewport () {
        my int32 ($x_ret, $y_ret);
        sub xdo_get_desktop_viewport(XDO, int32, int32) returns int32 is native('xdo') { * };
        xdo_get_desktop_viewport(self.id, $x_ret, $y_ret);
        $x_ret, $y_ret
    }

    #`[
    Set the position of the current viewport.

    This is only relevant if your window manager supports _NET_DESKTOP_VIEWPORT
    ]
    method set-desktop-viewport ($x, $y) {
        sub xdo_set_desktop_viewport(XDO, int32, int32) returns int32 is native('xdo') { * };
        xdo_set_desktop_viewport(self.id, $x, $y)
    }



    # Horrible hack frankensteined together from bits of libxdo and the Perl 6
    # X11::Xlib::Raw module to work around shortcomings / bugs in both.
    method get-windows () {
        my $display = XOpenDisplay("") or die 'Cannot open display';
        my $rootwin = $display.DefaultRootWindow;
        my $children := Pointer[Window].new;

        my %windows;

        get-children($display, $rootwin);

        for %windows.keys -> $w {
            %windows{$w}<name> = self.get-window-name(%windows{$w}<ID>);
            %windows{$w}<pid>  = self.get-window-pid(%windows{$w}<ID>);
        }

        sub get-children ($display, $window, $depth = 1) {
            #############################################################
            ## Need to include / modify some bits from NativeHelpers::Pointer
            ## Sigh,.
            #############################################################
            use nqp;
            NativeCall::Types::Pointer.^add_multi_method('add', method (Pointer:D: Int $off) {
                my \type = self.of;
                die "Can't do arithmetic with a void pointer" if type ~~ void;
                my int $a = nqp::unbox_i(nqp::decont(self)) + $off * nativesizeof(type);
                nqp::box_i($a, Pointer[type]);
            });

            multi sub infix:<+>(Pointer \p, Int $off) is export {
                p.add($off);
            }
            ################################################################

            XQueryTree($display, $window, my Window $root, my Window $parent, $children, my uint32 $n-children);
            return () unless $n-children;

            my XWindowAttributes $attr .= new;
            my XClassHint        $hint .= new;

            my @windows = gather for ^$n-children -> $i {
                my $w = ($children + $i).deref;
                XGetWindowAttributes($display, $w, $attr);
                take $w if $attr.map_state == IsViewable;
            }

            for @windows -> $w {
                my $res_name = XGetClassHint($display, $w, $hint) ?? $hint.res_name !! '';
                get-children($display, $w);
                if $res_name {
                    %windows{"$w"}<ID> = $w;
                    %windows{"$w"}<class> = $res_name;
                }
            }
        }
        %windows
    }

    method search (*%query) {
        my %w = self.get-windows();
        for %query.kv -> $param, $reg {
            note "$param is a invalid search parameter." and return ()
              unless $param ~~ 'name'|'class'|'ID'|'pid';
            for %w.values -> $w {
                return $w if $w{$param} ~~ /[$reg]/
            }
        }
        ()
    }
}
