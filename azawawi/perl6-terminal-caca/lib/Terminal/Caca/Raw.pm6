
use v6;

unit module Terminal::Caca::Raw;

use NativeCall;

# Colors
constant CACA_BLACK is export        = 0x00;
constant CACA_BLUE is export         = 0x01;
constant CACA_GREEN is export        = 0x02;
constant CACA_CYAN is export         = 0x03;
constant CACA_RED is export          = 0x04;
constant CACA_MAGENTA is export      = 0x05;
constant CACA_BROWN is export        = 0x06;
constant CACA_LIGHTGRAY is export    = 0x07;
constant CACA_DARKGRAY is export     = 0x08;
constant CACA_LIGHTBLUE is export    = 0x09;
constant CACA_LIGHTGREEN is export   = 0x0a;
constant CACA_LIGHTCYAN is export    = 0x0b;
constant CACA_LIGHTRED is export     = 0x0c;
constant CACA_LIGHTMAGENTA is export = 0x0d;
constant CACA_YELLOW is export       = 0x0e;
constant CACA_WHITE is export        = 0x0f;
constant CACA_DEFAULT is export      = 0x10;
constant CACA_TRANSPARENT is export  = 0x20;

# Events
constant CACA_EVENT_NONE is export          = 0x0000; # No event.
constant CACA_EVENT_KEY_PRESS is export     = 0x0001; # A key was pressed.
constant CACA_EVENT_KEY_RELEASE is export   = 0x0002; # A key was released.
constant CACA_EVENT_MOUSE_PRESS is export   = 0x0004; # A mouse button was pressed.
constant CACA_EVENT_MOUSE_RELEASE is export = 0x0008; # A mouse button was released.
constant CACA_EVENT_MOUSE_MOTION is export  = 0x0010; # The mouse was moved.
constant CACA_EVENT_RESIZE is export        = 0x0020; # The window was resized.
constant CACA_EVENT_QUIT is export          = 0x0040; # The user requested to quit.
constant CACA_EVENT_ANY is export           = 0xffff; # Bitmask for any event.

sub caca-library() {
    return "libcaca.so";
}

class CacaCanvas
    is repr('CPointer')
    is export { * }

class CacaDisplay
    is repr('CPointer')
    is export { * }

sub caca_create_display(CacaCanvas)
    returns CacaDisplay
    is export
    is native(&caca-library) { * }

sub caca_get_canvas(CacaDisplay)
    returns CacaCanvas
    is export
    is native(&caca-library) { * }

sub caca_set_display_title(CacaDisplay, Str)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_set_color_ansi(CacaCanvas, uint8, uint8)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_put_str(CacaCanvas, int32, int32, Str)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_refresh_display(CacaDisplay)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_get_event(CacaDisplay, int32, int32, int32)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_free_display(CacaDisplay)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_get_display_width(CacaDisplay)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_get_display_height(CacaDisplay)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_get_version()
    returns Str
    is export
    is native(&caca-library) { * }

sub caca_draw_line(CacaCanvas, int32, int32, int32, int32, uint32)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_draw_thin_line(CacaCanvas, int32, int32, int32, int32)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_draw_box(CacaCanvas, int32, int32, int32, int32, uint32)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_draw_thin_box(CacaCanvas, int32, int32, int32, int32)
    returns int32
    is export
    is native(&caca-library) { * }

sub caca_draw_circle(CacaCanvas, int32, int32, int32, uint32)
    returns int32
    is export
    is native(&caca-library) { * }
