#| Object-oriented GLFW window interface
unit class GLFW::Window is repr('CPointer');

use NativeCall;

need GLFW;
need GLFW::Monitor;
need GLFW::Image;

#| Creates a new window.  For fullscreen windows, pass a GLFW::Monitor
#| in $monitor.  To share resources with another window, pass another
#| GLFW::Window in $window.
method new($width, $height, $title, $monitor, $window) {
    create-window($width, $height, $title, $monitor, $window);
}

# FIXME: is this right?  Perl 6 docs seem to be limited to
# constructors, with no mention of destructors.  I'm going by RFC
# 189 for lack of a better resource.
submethod DESTROY {
    destroy-window(self);
}

#| Sets or gets whether the window should close (e.g. when the user
#| clicks the window's "close" button or equivalent).  Note that
#| actually setting this appears to be broken (it'll crash MoarVM), so
#| for now, setting this should be done through
#| GLFW::set-window-should-close.
method should-close() is rw {
    return Proxy.new(
        FETCH => sub ($) {
            window-should-close(self);
        },
        STORE => sub ($, $value) {
            # TODO: figure out why this causes MoarVM to panic
            set-window-should-close(self, $value);
        });
}

method title() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, $value) {
            set-window-title(self, $value);
        });
}

#| Set the window's title.
method icon() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, $value) {
            set-window-icon(self, $value);
        });
}

#| Get or set the window's position in screen units.  Accepts/returns
#| a list containing the X and Y coordinates.
method position() is rw {
    return Proxy.new(
        FETCH => sub ($) { get-window-position(self); },
        STORE => sub ($, $pos) {
            my (int32 $x, int32 $y) = $pos;
            set-window-position(self, $x, $y);
        });
}

#| Get or set the window's size in screen units.  Accepts/returns a
#| list containing the width and height.
method size() is rw {
    return Proxy.new(
        FETCH => sub ($) { get-window-size(self); },
        STORE => sub ($, $size) {
            my (int32 $width, int32 $height) = $size;
            set-window-size(self, $width, $height);
        });
}

# TODO: figure out a way to split this into min-size/max-size
# methods.  Not clear if it's possible to define fields for
# CPointer-based classes (if it is, then it also solves the
# problem of working around the lack of getters in the GLFW API).

#| Set the window's minimum/maximum sizes in screen units.  Accepts a
#| list containing the minimum and maximum sizes, each of which in
#| turn being a width/height list.
method size-limits() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, $limits) {
            my ($min, $max) = $limits;
            my ($min-w, $min-h) = $min;
            my ($max-w, $max-h) = $max;

            set-window-size-limits(self,
                                   $min-w, $min-h,
                                   $max-w, $max-h);
        });
}

#| Set the window's aspect ratio.
method aspect-ratio() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, $ratio) {
            my (int32 $numerator, int32 $denominator) = $ratio;
            set-window-aspect-ratio(self,
                                    $numerator,
                                    $denominator);
        });
}

#| Get or set the window's monitor (read: make the window fullscreen
#| on the given monitor).  Accepts a list with the monitor and
#| parameters, the latter of which is in turn a list with the position
#| (a list of coordinates in screen units), size/resolution (a list of
#| dimensions in screen units), and refresh rate (in Hz).
method monitor() is rw {
    return Proxy.new(
        FETCH => sub ($) { get-window-monitor(self); },
        STORE => sub ($, $args) {
            my (GLFW::Monitor $m, $params) = $args;
            my ($pos, $size, int32 $r) = $params;
            my (int32 $x, int32 $y) = $pos;
            my (int32 $w, int32 $h) = $size;

            set-window-monitor(self, $m, $x, $y, $w, $h, $r);
        });
}

#| Returns the value of the specified attribute.
method attribute($a) { get-window-attribute(self, $a); }

#| Gets or sets the window's "user pointer".
method user-pointer() is rw {
    return Proxy.new(
        FETCH => sub ($) { get-window-user-pointer(self); },
        STORE => sub ($, $pointer) {
            set-window-user-pointer(self, $pointer);
        });
}

#| Gets the size of the window's framebuffer in pixels (*not* screen
#| units).
method framebuffer-size() {
    my (int32 $width, int32 $height);
    get-framebuffer-size(self, $width, $height);
    return $width, $height
}

#| Gets the size of each edge of the window frame in screen units.
method frame-size() {
    my (int32 $left, int32 $top, int32 $right, int32 $bottom);
    get-window-frame-size(self, $left, $top, $right, $bottom);
    return $left, $top, $right, $bottom;
}

#| Iconifies the window
method iconify() { iconify-window(self); }

#| Restores the window
method restore() { restore-window(self); }

#| Maximizes the window
method maximize() { maximize-window(self); }

#| Shows the window
method show() { show-window(self); }

#| Hides the window
method hide() { hide-window(self); }

# FIXME: this probably doesn't work the way I'd like it to work
#| Gets/sets the window's input mode
method input-mode($mode) is rw {
    return Proxy.new(
        FETCH => sub ($) { get-input-mode(self, $mode); },
        STORE => sub ($, $value) {
            set-input-mode(self, $mode, $value);
        });
}

#| Gets the state of the specified key
method key($key) { get-key(self, $key); }

#| Gets the state of the specified mouse button
method mouse-button($button) { get-mouse-button(self, $button); }

#| Gets/sets the mouse cursor position
method cursor-position() is rw {
    return Proxy.new(
        FETCH => sub ($) {
            my (num64 $x, num64 $y);
            get-cursor-position(self, $x, $y);
            return $x, $y;
        },
        STORE => sub ($, $pos) {
            my (num64 $x, num64 $y) = $pos;
            set-cursor-position(self, $x, $y);
        });
}

#| Gets/sets the clipboard contents
method clipboard() is rw {
    return Proxy.new(
        FETCH => sub ($) { get-clipboard-string(self); },
        STORE => sub ($, $content) {
            set-clipboard-string(self, $content);
        });
}

#| Sets the window's context as the current context for OpenGL
#| rendering
method make-context-current() {
    make-context-current(self);
}

#| Swaps the window's buffers, causing the result of rendering
#| operations to be displayed in the window.
method swap-buffers() {
    swap-buffers(self);
}

#| Sets a callback to be run whenever the window is moved.  The
#| callback subroutine should accept a window, an X coordinate, and a
#| Y coordinate.
method position-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-window-position-callback(self, &callback);
        });
}

#| Sets a callback to be run whenever the window is resized.  The
#| callback subroutine should accept a window, a width, and a height.
method size-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-window-size-callback(self, &callback);
        });
}

#| Sets a callback to be run when the window is closed.  The callback
#| subroutine should accept a window.
method close-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-window-close-callback(self, &callback);
        });
}

#| Sets a callback to be run when the window's content is refreshed.
#| The callback subroutine should accept a window.
method refresh-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-window-refresh-callback(self &callback);
        });
}

#| Sets a callback to be run when the window is iconified.  The
#| callback subroutine should accept a window.
method iconify-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-window-iconify-callback(self, &callback);
        });
}

#| Sets a callback to be run whenever the window's framebuffer is
#| resized.  The callback subroutine should accept a window, a width,
#| and a height.
method framebuffer-size-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-framebuffer-size-callback(self, &callback);
        });
}

#| Sets a callback to be run whenever a key is pressed while the window
#| is focused.  The callback subroutine should accept a window, a GLFW
#| keycode, a system-specific scancode, an action
#| (press/release/repeat), and a modifier key bitmask.
method key-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-key-callback(self, &callback);
        });
}

#| Sets a callback to be run whenever the window receives a character.
#| The callback subroutine should accept a window and a Unicode code
#| point.
method char-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-char-callback(self, &callback);
        });
}

#| Equivalent to $window.char-callback, but with the addition of a
#| bitmask representing the active modifier keys.
method char-mods-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-char-mods-callback(self, &callback);
        });
}

#| Sets a callback to be run whenever the mouse cursor moves within
#| the window.  The callback subroutine should accept a window, the
#| new X coordinate, and the new Y coordinate.
method cursor-position-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-cursor-position-callback(self, &callback);
        });
}

#| Sets a callback to be run whenever the mouse cursor enters or
#| leaves the window.  The callback should accept a window and an
#| integer pretending to be a boolean.
method cursor-enter-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-cursor-enter-callback(self, &callback);
        });
}

#| Sets a callback to be run whenever the window is scrolled
#| (e.g. with the mouse scrollwheel).  The callback should accept a
#| window, a horizontal offset, and a vertical offset.
method scroll-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-scroll-callback(self, &callback);
        });
}

#| Sets a callback to be run whenever one or more files are dragged
#| and dropped onto the window.  The callback subroutine should accept
#| a window, the number of files, and a CArray of strings representing
#| the filenames/paths.  Note that since this is a CArray, you'll
#| probably want to convert it to a Perl array first (e.g. with
#| '@perlarray[$_] = $paths[$_] for ^$count;').
method drop-callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: no GLFW equivalent
        STORE => sub ($, &callback) {
            set-drop-callback(self, &callback);
        });
}




########################################################################
# Native C API                                                         #
########################################################################

our sub default-window-hints(
) is native('glfw') is symbol('glfwDefaultWindowHints') {*}

our sub window-hint(
    int32 $hint,
    int32 $value
) is native('glfw') is symbol('glfwWindowHint') {*}

our sub create-window(
    int32 $width,
    int32 $height,
    Str $title,
    GLFW::Monitor $monitor,
    GLFW::Window $share
) returns GLFW::Window is native('glfw') is symbol('glfwCreateWindow') {*}

our sub destroy-window(
    GLFW::Window $window
) is native('glfw') is symbol('glfwCreateWindow') {*}

our sub window-should-close(
    GLFW::Window $window
) returns Bool is native('glfw') is symbol('glfwWindowShouldClose') {*}

our sub set-window-should-close(
    GLFW::Window $window,
    int32(Bool) $value
) is native('glfw') is symbol('glfwSetWindowShouldClose') {*}

our sub set-window-title(
    GLFW::Window $window,
    Str $title
) is native('glfw') is symbol('glfwSetWindowTitle') {*}

our sub set-window-icon(
    GLFW::Window $window,
    int32 $count,
    CArray[GLFW::Image] $images
) is native('glfw') is symbol('glfwSetWindowIcon') {*}

our sub get-window-position(
    GLFW::Window $window,
    int32 $xpos is rw,
    int32 $ypos is rw
) is native('glfw') is symbol('glfwGetWindowPos') {*}

our sub set-window-position(
    GLFW::Window $window,
    int32 $xpos,
    int32 $ypos
) is native('glfw') is symbol('glfwSetWindowPos') {*}

our sub get-window-size(
    GLFW::Window $window,
    int32 $width is rw,
    int32 $height is rw
) is native('glfw') is symbol('glfwGetWindowSize') {*}

our sub set-window-size-limits(
    GLFW::Window $window,
    int32 $min-width,
    int32 $min-height,
    int32 $max-width,
    int32 $max-height
) is native('glfw') is symbol('glfwSetWindowSizeLimits') {*}

our sub set-window-aspect-ratio(
    GLFW::Window $window,
    int32 $numerator,
    int32 $denominator
) is native('glfw') is symbol('glfwSetWindowAspectRatio') {*}

our sub set-window-size(
    GLFW::Window $window,
    int32 $width,
    int32 $height
) is native('glfw') is symbol('glfwSetWindowSize') {*}

our sub get-framebuffer-size(
    GLFW::Window $window,
    int32 $width is rw,
    int32 $height is rw
) is native('glfw') is symbol('glfwGetFramebufferSize') {*}

our sub get-window-frame-size(
    GLFW::Window $window,
    int32 $left is rw,
    int32 $top is rw,
    int32 $right is rw,
    int32 $bottom is rw
) is native('glfw') is symbol('glfwGetWindowFrameSize') {*}

our sub iconify-window(
    GLFW::Window $window
) is native('glfw') is symbol('glfwIconifyWindow') {*}

our sub restore-window(
    GLFW::Window $window
) is native('glfw') is symbol('glfwRestoreWindow') {*}

our sub maximize-window(
    GLFW::Window $window
) is native('glfw') is symbol('glfwMaximizeWindow') {*}

our sub show-window(
    GLFW::Window $window
) is native('glfw') is symbol('glfwShowWindow') {*}

our sub hide-window(
    GLFW::Window $window
) is native('glfw') is symbol('glfwHideWindow') {*}

our sub focus-window(
    GLFW::Window $window
) is native('glfw') is symbol('glfwFocusWindow') {*}

our sub get-window-monitor(
    GLFW::Window $window
) returns GLFW::Monitor is native('glfw') is symbol('glfwGetWindowMonitor') {*}

our sub set-window-monitor(
    GLFW::Window $window,
    GLFW::Monitor $monitor,
    int32 $xpos,
    int32 $ypos,
    int32 $width,
    int32 $height,
    int32 $refresh-rate
) is native('glfw') is symbol('glfwSetWindowMonitor') {*}

our sub get-window-attribute(
    GLFW::Window $window,
    int32 $attrib
) returns int32 is native('glfw') is symbol('glfwGetWindowAttrib') {*}

our sub set-window-user-pointer(
    GLFW::Window $window,
    Pointer $pointer
) is native('glfw') is symbol('glfwSetWindowUserPointer') {*}

our sub get-window-user-pointer(
    GLFW::Window $window
) returns Pointer is native('glfw') is symbol('glfwGetWindowUserPointer') {*}

our sub set-window-position-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, int32, int32)
) is native('glfw') is symbol('glfwSetWindowPosCallback') {*}

our sub set-window-size-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, int32, int32)
) is native('glfw') is symbol('glfwSetWindowSizeCallback') {*}

our sub set-window-close-callback(
    GLFW::Window $window,
    &callback (GLFW::Window)
) is native('glfw') is symbol('glfwSetWindowCloseCallback') {*}

our sub set-window-refresh-callback(
    GLFW::Window $window,
    &callback (GLFW::Window)
) is native('glfw') is symbol('glfwSetWindowRefreshCallback') {*}

our sub set-window-iconify-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, int32)
) is native('glfw') is symbol('glfwSetWindowIconifyCallback') {*}

our sub set-framebuffer-size-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, int32, int32)
) is native('glfw') is symbol('glfwSetFramebufferSizeCallback') {*}

our sub get-input-mode(
    GLFW::Window $window,
    int32 $mode
) returns int32 is native('glfw') is symbol('glfwGetInputMode') {*}

our sub set-input-mode(
    GLFW::Window $window,
    int32 $mode,
    int32 $value
) is native('glfw') is symbol('glfwSetInputMode') {*}

our sub get-key(
    GLFW::Window $window,
    int32 $key
) returns int32 is native('glfw') is symbol('glfwGetKey') {*}

our sub get-mouse-button(
    GLFW::Window $window,
    int32 $button
) returns int32 is native('glfw') is symbol('glfwGetMouseButton') {*}

our sub get-cursor-position(
    GLFW::Window $window,
    num64 $xpos is rw,
    num64 $ypos is rw
) is native('glfw') is symbol('glfwGetCursorPos') {*}

our sub set-cursor-position(
    GLFW::Window $window,
    num64 $xpos,
    num64 $ypos
) is native('glfw') is symbol('glfwSetCursorPos') {*}

our sub set-key-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, int32, int32, int32, int32)
) is native('glfw') is symbol('glfwSetKeyCallback') {*}

our sub set-char-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, uint32)
) is native('glfw') is symbol('glfwSetCharCallback') {*}

our sub set-char-mods-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, uint32, int32)
) is native('glfw') is symbol('glfwSetCharModsCallback') {*}

our sub set-mouse-button-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, int32, int32, int32)
) is native('glfw') is symbol('glfwSetMouseButtonCallback') {*}

our sub set-cursor-position-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, num64, num64)
) is native('glfw') is symbol('glfwSetCursorPosCallback') {*}

our sub set-cursor-enter-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, int32)  # FIXME: should arg2 be int32(Bool)?
) is native('glfw') is symbol('glfwSetCursorEnterCallback') {*}

our sub set-scroll-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, num64, num64)
) is native('glfw') is symbol('glfwSetScrollCallback') {*}

our sub set-drop-callback(
    GLFW::Window $window,
    &callback (GLFW::Window, Array[Str])
) is native('glfw') is symbol('glfwSetDropCallback') {*}

our sub set-clipboard-string(
    GLFW::Window $window,
    Str $string
) is native('glfw') is symbol('glfwSetClipboardString') {*}

our sub get-clipboard-string(
    GLFW::Window $window
) returns Str is native('glfw') is symbol('glfwGetClipboardString') {*}

our sub make-context-current(
    GLFW::Window $window
) is native('glfw') is symbol('glfwMakeContextCurrent') {*}

our sub swap-buffers(
    GLFW::Window $window
) is native('glfw') is symbol('glfwSwapBuffers'){*}
