
use v6;

unit class Terminal::Caca;

use NativeCall;
use Terminal::Caca::Raw;

# Fields
has CacaDisplay $!dp;
has CacaCanvas  $!cv;

# Color Enumeration
enum CacaColor is export (
    black         => CACA_BLACK,
    blue          => CACA_BLUE,
    green         => CACA_GREEN,
    cyan          => CACA_CYAN,
    red           => CACA_RED,
    magenta       => CACA_MAGENTA,
    brown         => CACA_BROWN,
    light-gray    => CACA_LIGHTGRAY,
    dark-gray     => CACA_DARKGRAY,
    light-blue    => CACA_LIGHTBLUE,
    light-green   => CACA_LIGHTGREEN,
    light-cyan    => CACA_LIGHTCYAN,
    light-red     => CACA_LIGHTRED,
    light-magenta => CACA_LIGHTMAGENTA,
    yellow        => CACA_YELLOW,
    white         => CACA_WHITE,
    color-default => CACA_DEFAULT,
    transparent   => CACA_TRANSPARENT,
);

enum CacaEvent is export (
     event-none    => CACA_EVENT_NONE,          #  No event.
     key-press     => CACA_EVENT_KEY_PRESS,     #  A key was pressed.
     key-release   => CACA_EVENT_KEY_RELEASE,   #  A key was released.
     mouse-press   => CACA_EVENT_MOUSE_PRESS,   #  A mouse button was pressed.
     mouse-release => CACA_EVENT_MOUSE_RELEASE, #  A mouse button was released.
     mouse-motion  => CACA_EVENT_MOUSE_MOTION,  #  The mouse was moved.
     resize        => CACA_EVENT_RESIZE,        #  The window was resized.
     quit          => CACA_EVENT_QUIT,          #  The user requested to quit.
     event-any     => CACA_EVENT_ANY,           #  Any event.
);

#
# Error checking utility methods
#
method _check_display_handle {
    die "Display handle not initialized" unless $!dp
}

method _check_canvas_handle {
    die "Canvas handle not initialized" unless $!cv
}

method _check_return_result($ret) {
    die "Invalid return result" unless $ret == 0
}

method _ensure_one_char(Str $char) {
    warn "A single character is expected" unless $char.chars == 1
}

# Constructor
submethod BUILD {
    my $NULL = CacaDisplay.new;
    $!dp     = caca_create_display($NULL);
    self._check_display_handle;
    $!cv     = caca_get_canvas($!dp);
    self._check_canvas_handle
}

# This should be called on scope exit to perform cleanup
method cleanup {
    self._check_display_handle;
    my $ret = caca_free_display($!dp);
    warn "Invalid return result" if $ret != 0
}

submethod version returns Str {
    caca_get_version
}

method refresh {
    self._check_display_handle;
    my $ret = caca_refresh_display($!dp);
    self._check_return_result($ret)
}

method title(Str $title) {
    self._check_display_handle;
    my $ret = caca_set_display_title($!dp, $title);
    self._check_return_result($ret)
}

method color(
    CacaColor $fore-color = white,
    CacaColor $back-color = black)
{
    self._check_canvas_handle;
    my $ret = caca_set_color_ansi($!cv, $fore-color, $back-color);
    self._check_return_result($ret)
}

method text(Int $x, Int $y, Str $string) returns Int {
    self._check_canvas_handle;
    caca_put_str($!cv, $x, $y, $string)
}

method line(Int $x1, Int $y1, Int $x2, Int $y2, Str $char = '#') {
    self._check_canvas_handle;
    self._ensure_one_char($char);
    my $ret = caca_draw_line($!cv, $x1, $y1, $x2, $y2, $char.ord);
    self._check_return_result($ret)
}

method thin-line(Int $x1, Int $y1, Int $x2, Int $y2) {
    self._check_canvas_handle;
    my $ret = caca_draw_thin_line($!cv, $x1, $y1, $x2, $y2);
    self._check_return_result($ret)
}

method box(Int $x, Int $y, Int $width, Int $height, Str $char = '#') {
    self._check_canvas_handle;
    self._ensure_one_char($char);
    my $ret = caca_draw_box($!cv, $x, $y, $width, $height, $char.ord);
    self._check_return_result($ret)
}

method thin-box(Int $x, Int $y, Int $width, Int $height) {
    self._check_canvas_handle;
    my $ret = caca_draw_thin_box($!cv, $x, $y, $width, $height);
    self._check_return_result($ret)
}

method cp437-box(Int $x, Int $y, Int $width, Int $height) {
    self._check_canvas_handle;
    my $ret = caca_draw_cp437_box($!cv, $x, $y, $width, $height);
    self._check_return_result($ret)
}

method fill-box(Int $x, Int $y, Int $width, Int $height, Str $char = '#') {
    self._check_canvas_handle;
    self._ensure_one_char($char);
    my $ret = caca_fill_box($!cv, $x, $y, $width, $height, $char.ord);
    self._check_return_result($ret)
}

method circle(Int $x, Int $y, Int $radius, Str $char = '#') {
    self._check_canvas_handle;
    self._ensure_one_char($char);
    my $ret = caca_draw_circle($!cv, $x, $y, $radius, $char.ord);
    self._check_return_result($ret)
}

method ellipse(Int $x, Int $y, Int $x-radius, Int $y-radius, Str $char = '#') {
    self._check_canvas_handle;
    self._ensure_one_char($char);
    my $ret = caca_draw_ellipse($!cv, $x, $y, $x-radius, $y-radius, $char.ord);
    self._check_return_result($ret)
}

method thin-ellipse(Int $x, Int $y, Int $x-radius, Int $y-radius) {
    self._check_canvas_handle;
    my $ret = caca_draw_thin_ellipse($!cv, $x, $y, $x-radius, $y-radius);
    self._check_return_result($ret)
}

method fill-ellipse(Int $x, Int $y, Int $x-radius, Int $y-radius, Str $char = '#') {
    self._check_canvas_handle;
    self._ensure_one_char($char);
    my $ret = caca_fill_ellipse($!cv, $x, $y, $x-radius, $y-radius, $char.ord);
    self._check_return_result($ret)
}

method triangle(Int $x1, Int $y1, Int $x2, Int $y2, Int $x3, Int $y3, Str $char = '#') {
    self._check_canvas_handle;
    self._ensure_one_char($char);
    my $ret = caca_draw_triangle($!cv, $x1, $y1, $x2, $y2, $x3, $y3, $char.ord);
    self._check_return_result($ret)
}

method thin-triangle(Int $x1, Int $y1, Int $x2, Int $y2, Int $x3, Int $y3) {
    self._check_canvas_handle;
    my $ret = caca_draw_thin_triangle($!cv, $x1, $y1, $x2, $y2, $x3, $y3);
    self._check_return_result($ret)
}

method fill-triangle(Int $x1, Int $y1, Int $x2, Int $y2, Int $x3, Int $y3, Str $char = '#') {
    self._check_canvas_handle;
    self._ensure_one_char($char);
    my $ret = caca_fill_triangle($!cv, $x1, $y1, $x2, $y2, $x3, $y3, $char.ord);
    self._check_return_result($ret)
}

method polyline(@points, Str $char = '#') {
    self._check_canvas_handle;
    self._ensure_one_char($char);

    # Copy x/y values to C Arrays
    my $size     = @points.elems;
    my $x-carray = CArray[int32].new;
    my $y-carray = CArray[int32].new;
    for 0..$size - 1 -> $i  {
        $x-carray[$i] = @points[$i][0];
        $y-carray[$i] = @points[$i][1];
    }

    my $ret = caca_draw_polyline($!cv, $x-carray, $y-carray, $size - 1, $char.ord);
    self._check_return_result($ret)
}

method thin-polyline(@points) {
    self._check_canvas_handle;

    # Copy x/y values to C Arrays
    my $size     = @points.elems;
    my $x-carray = CArray[int32].new;
    my $y-carray = CArray[int32].new;
    for 0..$size - 1 -> $i  {
        $x-carray[$i] = @points[$i][0];
        $y-carray[$i] = @points[$i][1];
    }

    my $ret = caca_draw_thin_polyline($!cv, $x-carray, $y-carray, $size - 1);
    self._check_return_result($ret)
}

method clear {
    self._check_canvas_handle;
    my $ret = caca_clear_canvas($!cv);
    self._check_return_result($ret)
}

method wait-for-keypress {
    self.wait-for-event(CACA_EVENT_KEY_PRESS, -1);
}

method wait-for-event($mask = event-any, $timeout = 0) returns Int {
    self._check_display_handle;
    #TODO fill event structure (3rd parameter)
    caca_get_event($!dp, $mask, 0, $timeout)
}

method random-color returns CacaColor {
    CacaColor((black..white).pick)
}

method width {
    self._check_display_handle;
    caca_get_display_width( $!dp )
}

method height {
    self._check_display_handle;
    caca_get_display_height( $!dp )
}

method size {
    self.width, self.height
}

method mouse-x {
    self._check_display_handle,
    caca_get_mouse_x($!dp)
}

method mouse-y {
    self._check_display_handle,
    caca_get_mouse_y($!dp)
}

method mouse-position {
    self.mouse-x, self.mouse-y
}

method cursor(Bool $enable) {
    self._check_display_handle;
    caca_set_cursor($!dp, $enable ?? 1 !! 0)
}

method invert {
     self._check_canvas_handle;
     caca_invert($!cv)
}

method flip {
    self._check_canvas_handle;
    caca_flip($!cv)
}

method flop {
    self._check_canvas_handle;
    caca_flop($!cv)
}

method rotate180 {
    self._check_canvas_handle;
    caca_rotate_180($!cv)
}

method rotate-left {
    self._check_canvas_handle;
    caca_rotate_left($!cv)
}

method rotate-right {
    self._check_canvas_handle;
    caca_rotate_right($!cv)
}

method stretch-left {
    self._check_canvas_handle;
    caca_stretch_left($!cv)
}

method stretch-right {
    self._check_canvas_handle;
    caca_stretch_right($!cv)
}

method dither-image($width, $height, $image-pixels) {
    self._check_canvas_handle;

    #TODO generalize those parameters and simplify
    my $bpp        = 24;
    my $depth      = 3;
    my $red-mask   = 0x000000ff;
    my $green-mask = 0x0000ff00;
    my $blue-mask  = 0x00ff0000;
    my $alpha-mask = 0x00000000;
    my $dither     = caca_create_dither($bpp, $width, $height, $depth * $width,
        $red-mask, $green-mask, $blue-mask, $alpha-mask);
    die "Invalid dither" unless $dither;

    my ($ww, $wh)    = self.size;
    my $image-carray = CArray[uint8].new;
    for 0..$image-pixels.elems - 1 -> $i  {
        $image-carray[$i] = $image-pixels[$i];
    }
    #TODO no magic numbers
    caca_dither_bitmap($!cv, 0,0, 79, 31, $dither, $image-carray);

    # Cleanup
    LEAVE {
        caca_free_dither($dither) if $dither
    }
}
