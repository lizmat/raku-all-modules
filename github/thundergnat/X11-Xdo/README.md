NAME
====

X11::Xdo

Version: 0.1.0

Perl 6 bindings to the [libxdo X11 automation library](https://github.com/jordansissel/xdotool).

Note: This is a WORK IN PROGRESS. The tests are under construction and many of them may not work on your computer. Several functions are not yet implemented, but a large core group is.

Many of the test files do not actally run tests that can be checked for correctness. (Many of the object move & resize tests for example.) Rather, they attempt to perform an action and fail/pass based on if the attempt does or doesn't produce an error.

Not all libxdo functions are supported by every window manager. In general, mouse info & move and window info, move, & resize routines seem to be well supported, others... not so much.

SYNOPSIS
========

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

DESCRIPTION
===========

Perl 6 bindings to the [libxdo X11 automation library](https://github.com/jordansissel/xdotool).

Requires that libxdo-dev library is installed and accessible.

<table class="pod-table">
<thead><tr>
<th>Platform</th> <th>Install Method</th>
</tr></thead>
<tbody>
<tr> <td>Debian and Ubuntu</td> <td>[sudo] apt-get install libxdo-dev</td> </tr> <tr> <td>FreeBSD</td> <td>[sudo] pkg install libxdo-dev</td> </tr> <tr> <td>Fedora</td> <td>[sudo] dnf install libxdo-dev</td> </tr> <tr> <td>OSX</td> <td>[sudo] brew install libxdo-dev</td> </tr> <tr> <td>OpenSUSE</td> <td>[sudo] zypper install libxdo-dev</td> </tr> <tr> <td>Source Code on GitHub</td> <td>https://github.com/jordansissel/xdotool/releases</td> </tr>
</tbody>
</table>

Many (most?) of the xdo methods take a window ID # in their parameters. This is an integer ID# and MUST be passed as an unsigned Int. In general, to act on the currently active window, set the window ID to 0 or just leave blank.

Note that many of the methods will require a small delay for them to finish before moving on to the next, especially when performing several actions in a row. Either do a short sleep or a .activate-window($window-ID) to give the action time to complete before moving on to the next action.

There are several broad categories of methods available.

  * Misc

  * Mouse

  * Window

  * Keystrokes

  * Desktop

Miscellaneous
-------------

    .version()

Get the library version.

Takes no parameters.

Returns the version string of the current libxdo library.

--

    .get_symbol_map()

Get modifier symbol pairs.

Takes no parameters.

Returns an array of modifier symbol pairs.

--

    .search(%query)

Reimplementation of the libxdo search function to give greater flexibility under Perl 6.

May seach for a name, class, ID or pid or any combination, against a string / regex.

    .search( :name(), :class(), :ID(), :pid() )

Search for an open window where the title contains the exact string 'libxdo':

    .search( :name('libxdo') )

Search for an open window where the title contains 'Perl' case insensitvely:

    .search( :name(rx:i['perl']) )

Returns a hash { :name(), :class(), :ID(), :pid() } pairs of the first match found for one of the search parameters.

if you need more granularity or control over the search, use get-windows to get a hash of all of the visible windows and search through them manually.

--

    .get-windows()

Takes no parameters.

Returns a hoh of all of the visible windows keyed on the ID number with value of a hash of { :name(), :class(), :ID(), :pid() } pairs.

Mouse
-----

    .move-mouse( $x, $y, $screen )

Move the mouse to a specific location.

Takes three parameters:

  * int $x: the target X coordinate on the screen in pixels.

  * int $y: the target Y coordinate on the screen in pixels.

  * int $screen the screen (number) you want to move on.

Returns 0 on success !0 on failure.

--

    .move-mouse-relative( $delta-x, $delta-y )

Move the mouse relative to it's current position.

Takes two parameters:

  * int $delta-x: the distance in pixels to move on the X axis.

  * int $delta-y: the distance in pixels to move on the Y axis.

Returns 0 on success !0 on failure.

--

    .move-mouse-relative-to-window( $x, $y, $window )

Move the mouse to a specific location relative to the top-left corner of a window.

Takes three parameters:

  * int $x: the target X coordinate on the screen in pixels.

  * int $y: the target Y coordinate on the screen in pixels.

  * Window $window: ID of the window.

Returns 0 on success !0 on failure.

--

    .get-mouse-location()

Get the current mouse location (coordinates and screen ID number).

Takes no parameters;

Returns three integers:

  * int $x: the x coordinate of the mouse pointer.

  * int $y: the y coordinate of the mouse pointer.

  * int $screen: the index number of the screen the mouse pointer is located on.

--

    .get-mouse-info()

Get all mouse location-related data.

Takes no parameters;

Returns four integers:

  * int $x: the x coordinate of the mouse pointer.

  * int $y: the y coordinate of the mouse pointer.

  * Window $window: the ID number of the window the mouse pointer is located on.

  * int $screen: the index number of the screen the mouse pointer is located on.

--

    .wait-for-mouse-to-move-from( $origin-x, $origin-y )

Wait for the mouse to move from a location. This function will block until the condition has been satisfied.

Takes two integer parameters:

  * int $origin-x: the X position you expect the mouse to move from.

  * int $origin-y: the Y position you expect the mouse to move from.

Returns nothing.

--

    .wait-for-mouse-to-move-to( $dest-x, $dest-y )

Wait for the mouse to move to a location. This function will block until the condition has been satisfied.

Takes two integer parameters:

  * int $dest-x: the X position you expect the mouse to move to.

  * int $dest-y: the Y position you expect the mouse to move to.

Returns nothing.

--

    .mouse-button-down( $window, $button )

Send a mouse press (aka mouse down) for a given button at the current mouse location.

Takes two parameters:

  * Window $window: The ID# of the window receiving the event. 0 for the current window.

  * int $button: The mouse button. Generally, 1 is left, 2 is middle, 3 is right, 4 is wheel up, 5 is wheel down.

Returns nothing.

--

    .mouse-button-up( $window, $button )

Send a mouse release (aka mouse up) for a given button at the current mouse location.

Takes two parameters:

  * Window $window: The ID# of the window receiving the event. 0 for the current window.

  * int $button: The mouse button. Generally, 1 is left, 2 is middle, 3 is right, 4 is wheel up, 5 is wheel down.

Returns nothing.

--

    .mouse-button-click( $window, $button )

Send a click for a specific mouse button at the current mouse location.

Takes two parameters:

  * Window $window: The ID# of the window receiving the event. 0 for the current window.

  * int $button: The mouse button. Generally, 1 is left, 2 is middle, 3 is right, 4 is wheel up, 5 is wheel down.

Returns nothing.

--

    .mouse-button-multiple( $window, $button, $repeat = 2, $delay? )

Send a one or more clicks of a specific mouse button at the current mouse location.

Takes three parameters:

  * Window $window: The ID# of the window receiving the event. 0 for the current window.

  * int $button: The mouse button. Generally, 1 is left, 2 is middle, 3 is right, 4 is wheel up, 5 is wheel down.

  * int $repeat: (optional, defaults to 2) number of times to click the button.

  * int $delay: (optional, defaults to 8000) useconds delay between clicks. 8000 is a reasonable default.

Returns nothing.

--

    .get-window-under-mouse()

Get the window the mouse is currently over

Takes no parameters.

Returns the ID of the topmost window under the mouse.

Window
------

    .get-active-window()

Get the currently-active window. Requires your window manager to support this.

Takes no parameters.

Returns one integer:

  * $screen: Window ID of active window.

--

    .select-window-with-mouse()

Get a window ID by clicking on it. This function blocks until a selection is made.

Takes no parameters.

Returns one integer:

  * $screen: Window ID of active window.

--

    .get-window-location( $window?, $scrn? )

Get a window's location.

Takes two optional parameters:

  * Window $window: Optional parameter window ID. If none supplied, uses active window ID.

  * int $screen: Optional parameter screen ID. If none supplied, uses active screen ID.

Returns three integers:

  * $x: x coordinate of top left corner of window.

  * $y: y coordinate of top left corner of window.

  * $screen index of screen the window is located on.

--

    .get-window-size( $window? )

Get a window's size.

Takes one optional parameter:

  * Window $window: Optional parameter window ID. If none supplied, uses active window ID.

Returns two integers:

  * int $width the width of the queried window in pixels.

  * int $height the height of the queried window in pixels.

--

    .get-window-geometry( $window? )

Get a windows geometry string.

Takes one optional parameter:

  * Window $window: Optional parameter window ID. If none supplied, uses active window ID.

Returns standard geometry string

  * Str $geometry "{$width}x{$height}+{$x}+{$y}" format

400x200+250+450 means a 400 pixel wide by 200 pixel high window with the top left corner at 250 x position 450 y position.

--

    .get-window-name( $window? )

Get a window's name, if any.

Takes one optional parameter:

  * Window $window: Optional parameter window ID. If none supplied, uses active window ID.

Returns one string:

  * Str $name Name of the queried window.

--

    .get-window-pid( $window )

Get the PID or the process owning a window. Not all applications support this. It looks at the _NET_WM_PID property of the window.

Takes one parameter:

  * Window $window: Window ID.

Returns one integer:

  * int $pid process id, or 0 if no pid found.

--

    .set-window-size( $window, $width, $height, $flags? = 0 )

Set the window size.

Takes four parameters:

  * Window $window: the ID of the window to resize.

  * int $width: the new desired width.

  * int $height: the new desired height

  * int $flags: Optional, if 0, use pixels for units. Otherwise the units will be relative to the window size hints.

HINTS:

  * 0 size window in pixels

  * 1 size X dimension relative to character block width

  * 2 size Y dimension relative to character block height

  * 3 size both dimensions relative to character block size

Returns 0 on success !0 on failure.

--

    .focus-window( $window )

Set the focus on a window.

Takes one parameter:

  * Window $window: ID of window to focus on.

Returns 0 on success !0 on failure.

--

    .get-focused-window( )

Get the ID of the window currently having focus.

Takes no parameters:

Returns one parameter:

  * Window $window: ID of window currently having focus.

--

    .activate-window( $window )

Activate a window. This is generally a better choice than .focus_window for a variety of reasons, but it requires window manager support.

  * If the window is on another desktop, that desktop is switched to.

  * It moves the window forward rather than simply focusing it

Takes one parameter:

  * Window $window: Window ID.

Returns 0 on success !0 on failure.

--

    .raise-window( $window )

Raise a window to the top of the window stack. This is also sometimes termed as bringing the window forward.

Takes one parameter:

  * Window $window: Window ID.

Returns 0 on success !0 on failure.

--

    .minimize( $window )

Minimize a window.

Takes one parameter:

  * Window $window: Window ID.

Returns 0 on success !0 on failure.

--

    .map-window( $window )

Map a window. This mostly means to make the window visible if it is not currently mapped.

Takes one parameter:

  * Window $window: Window ID.

Returns 0 on success !0 on failure.

--

    .unmap-window( $window )

Unmap a window. This means to make the window invisible and possibly remove it from the task bar on some WMs.

Takes one parameter:

  * Window $window: Window ID.

Returns 0 on success !0 on failure.

--

    .move-window( $window )

Move a window to a specific location.

The top left corner of the window will be moved to the x,y coordinate.

Takes three parameters:

  * Window $window: Window ID of the window to move.

  * int $x : the X coordinate to move to.

  * int $y: the Y coordinate to move to.

Returns 0 on success !0 on failure.

--

    .wait_for_window_active( $window )

Wait for a window to be active or not active. Requires your window manager to support this. Uses _NET_ACTIVE_WINDOW from the EWMH spec.

Takes one parameter:

  * Window $window: Window ID. If none supplied, uses active window ID.

Returns 0 on success !0 on failure.

--

    .close-window( $window )

TODO not working under Cinnamon?

Close a window without trying to kill the client.

Takes one parameter:

  * Window $window: Optional parameter window ID. If none supplied, uses active window ID.

Returns 0 on success !0 on failure.

--

    .kill-window( $window )

TODO not working under Cinnamon?

Kill a window and the client owning it.

Takes one parameter:

  * Window $window: Optional parameter window ID. If none supplied, uses active window ID.

Returns 0 on success !0 on failure.

--

    .override-redirect( $window, $value )

TODO not working under Cinnamon?

Set the override_redirect value for a window. This generally means whether or not a window manager will manage this window.

Takes two parameters:

  * Window $window: Optional parameter window ID. If none supplied, uses active window ID.

  * int $value: If you set it to 1, the window manager will usually not draw borders on the window, etc. If you set it to 0, the window manager will see it like a normal application window.

Returns 0 on success !0 on failure.

--

    .wait-for-window-map-state( $window, $state )

Wait for a window to have a specific map state.

State possibilities:

  * 0 IsUnmapped - window is not displayed.

  * 1 IsViewable - window is mapped and shown (though may be clipped by windows on top of it)

  * 2 IsUnviewable - window is mapped but a parent window is unmapped.

Takes two parameters:

  * Window $window: Window ID, the window you want to wait for.

  * int map_state: the state to wait for.

--

    .set-window-state( $window, $action, $property)

Change window state

Takes three parameters:

  * Window $window: Window ID, the window you want to act on.

  * ulong $action: the _NET_WM_STATE action

  * str $property: the property to change

--

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

Retuns 0 on sucess, !0 on failure

Keystrokes
----------

    .type( $window, $string, $delay? )

Type a string to the specified window.

If you want to send a specific key or key sequence, such as "alt+l", you want instead send-sequence(...).

Not well supported under many window managers or by many applications unfortunately. Somewhat of a crapshoot as to which applications pay attention to this function. Web browsers tend to; (Firefox and Chrome tested), many other applications do not. Need to try it to see if it will work in your situation.

Takes three parameters:

  * int $window: The window you want to send keystrokes to or 0 for the current window.

  * string $string: The string to type, like "Hello world!"

  * int $delay: Optional delay between keystrokes in microseconds. 12000 is a decent choice if you don't have other plans.

Returns 0 on success !0 on failure.

--

    .send-sequence( $window, $string, $delay? )

This allows you to send keysequences by symbol name. Any combination of X11 KeySym names separated by '+' are valid. Single KeySym names are valid, too.

Examples: "l" "semicolon" "alt+Return" "Alt_L+Tab"

Takes three parameters:

  * int $window: The window you want to send keystrokes to or 0 for the current window.

  * string $string: The string keysequence to send.

  * int $delay: Optional delay between keystrokes in microseconds. 12000 is a decent choice if you don't have other plans.

Returns 0 on success !0 on failure.

--

    .send-key-press( $window, $string, $delay? )

Send key press (down) events for the given key sequence.

See send-sequence

Takes three parameters:

  * int $window: The window you want to send keystrokes to or 0 for the current window.

  * string $string: The string keysequence to send.

  * int $delay: Optional delay between key down events in microseconds.

Returns 0 on success !0 on failure.

--

    .send-key-release( $window, $string, $delay? )

Send key release (up) events for the given key sequence.

See send-sequence

Takes three parameters:

  * int $window: The window you want to send keystrokes to or 0 for the current window.

  * string $string: The string keysequence to send.

  * int $delay: Optional delay between key down events in microseconds.

Returns 0 on success !0 on failure.

Desktop
-------

    .get-desktop-dimensions( $screen? )

Query the viewport (your display) dimensions

If Xinerama is active and supported, that api internally is used. If Xinerama is disabled, will report the root window's dimensions for the given screen.

Takes one parameter:

  * int $screen: Optional parameter screen index. If none supplied, uses default 0.

Returns three integers:

  * $x: x dimension of the desktop window.

  * $y: y dimension of the desktop window.

  * $screen index of screen for which the dimensions are reported.

--

    .set-number-of-desktops($number)

Set the number of desktops. Uses _NET_NUMBER_OF_DESKTOPS of the EWMH spec.

Takes one parameter:

  * $ndesktops: the new number of desktops to set.

Returns 0 on success, !0 on failure

--

    .get-number-of-desktops()

Get the current number of desktops. Uses _NET_NUMBER_OF_DESKTOPS of the EWMH spec.

Takes no parameters:

Returns one integer:

  * $number: the current number of desktops (workspaces).

--

    .set-current-desktop($number)

Switch to another desktop. Uses _NET_CURRENT_DESKTOP of the EWMH spec.

Takes one parameter:

  * int $number The desktop number to switch to.

--

    .get-current-desktop()

Get the current desktop. Uses _NET_CURRENT_DESKTOP of the EWMH spec.

Takes no parmeters:

Returns one integer:

  * int $number The index number of the current desktop (workspace).

--

    .move-window-to-desktop($window, $number)

Move a window to another desktop. Uses _NET_WM_DESKTOP of the EWMH spec.

Takes two parameters:

  * Window $window: ID of the window to move

  * int $desktop: the desktop destination for the window

Returns 0 on success, !0 on failure

--

    .get-desktop-for-window($window)

Get the desktop a window is on. Uses _NET_WM_DESKTOP of the EWMH spec.

If your desktop does not support _NET_WM_DESKTOP ruturns Nil.

Takes one parameter:

  * Window $window: ID of the window to query.

Returns one integer:

  * int $desktop: the desktop where the window is located.

--

    .get-desktop-viewport()

Get the position of the current viewport.

This is only relevant if your window manager supports _NET_DESKTOP_VIEWPORT

Takes no parameters:

Returns two values:

  * int $x: the X value of the top left corner of the viewport.

  * int $y: the Y value of the top left corner of the viewport.

--

    .set-desktop-viewport($x, $y)

Set the position of the current viewport.

This is only relevant if your window manager supports _NET_DESKTOP_VIEWPORT

Takes two parameters:

  * int $x: the X value of the top left corner of the viewport.

  * int $y: the Y value of the top left corner of the viewport.

AUTHOR
======

2018 Steve Schulze aka thundergnat

This package is free software and is provided "as is" without express or implied warranty. You can redistribute it and/or modify it under the same terms as Perl itself.

LICENSE
=======

Licensed under The Artistic 2.0; see LICENSE.

