
use v6;

# Cooked API :)
unit class Terminal::Caca;

use Terminal::Caca::Raw;

# Fields
has CacaDisplay $!dp;
has CacaCanvas $!cv;

enum CacaColor is export (
    Black        => CACA_BLACK,
    Blue         => CACA_BLUE,
    Green        => CACA_GREEN,
    Cyan         => CACA_CYAN,
    Red          => CACA_RED,
    Magenta      => CACA_MAGENTA,
    Brown        => CACA_BROWN,
    LightGray    => CACA_LIGHTGRAY,
    DarkGray     => CACA_DARKGRAY,
    LightBlue    => CACA_LIGHTBLUE,
    LightGreen   => CACA_LIGHTGREEN,
    LightCyan    => CACA_LIGHTCYAN,
    LightRed     => CACA_LIGHTRED,
    LightMagenta => CACA_LIGHTMAGENTA,
    Yellow       => CACA_YELLOW,
    White        => CACA_WHITE,
    Default      => CACA_DEFAULT,
    Transparent  => CACA_TRANSPARENT,
);

submethod BUILD {
    my $NULL = CacaDisplay.new;
    $!dp     = caca_create_display($NULL);
    die "Could create display handle" unless $!dp;
    $!cv     = caca_get_canvas($!dp);
    die "Could create canvas handle"  unless $!cv;
}

method cleanup {
    die "Display handle not initialized" unless $!dp;
    my $ret = caca_free_display($!dp);
    die "Invalid return result" unless $ret == 0;
}

submethod version returns Str {
    return caca_get_version;
}

method refresh {
    die "Display handle not initialized" unless $!dp;
    my $ret = caca_refresh_display($!dp);
    die "Invalid return result" unless $ret == 0;
}

method title($title) {
    die "Display handle not initialized" unless $!dp;
    my $ret = caca_set_display_title($!dp, $title);
    die "Invalid return result" unless $ret == 0;
}

method color-ansi($fore-color = White, $back-color = Black) {
    die "Canvas handle not initialized" unless $!cv;
    my $ret = caca_set_color_ansi($!cv, $fore-color, $back-color);
    die "Invalid return result" unless $ret == 0;
}

method put-str(Int $x, Int $y, Str $string) returns Int {
    die "Canvas handle not initialized" unless $!cv;
    caca_put_str($!cv, $x, $y, $string);
}

method line(Int $x1, Int $y1, Int $x2, Int $y2, Str $char = '#') {
    die "Canvas handle not initialized" unless $!cv;
    die "A single character is expected" unless $char.chars == 1;
    my $ret = caca_draw_line($!cv, $x1, $y1, $x2, $y2, $char.ord);
    die "Invalid return result" unless $ret == 0;
}

method thin-line(Int $x1, Int $y1, Int $x2, Int $y2) {
    die "Canvas handle not initialized" unless $!cv;
    my $ret = caca_draw_thin_line($!cv, $x1, $y1, $x2, $y2);
    die "Invalid return result" unless $ret == 0;
}

method box(Int $x1, Int $y1, Int $x2, Int $y2, Str $char = '#') {
    die "Canvas handle not initialized" unless $!cv;
    die "A single character is expected" unless $char.chars == 1;
    my $ret = caca_draw_box($!cv, $x1, $y1, $x2, $y2, $char.ord);
    die "Invalid return result" unless $ret == 0;
}

method thin-box(Int $x1, Int $y1, Int $x2, Int $y2) {
    die "Canvas handle not initialized" unless $!cv;
    my $ret = caca_draw_thin_box($!cv, $x1, $y1, $x2, $y2);
    die "Invalid return result" unless $ret == 0;
}

method circle(Int $x, Int $y, Int $radius, Str $char = '#') {
    die "Canvas handle not initialized" unless $!cv;
    die "A single character is expected" unless $char.chars == 1;
    my $ret = caca_draw_circle($!cv, $x, $y, $radius, $char.ord);
    die "Invalid return result" unless $ret == 0;
}

method wait-for-keypress {
    die "Display handle not initialized" unless $!dp;
    my $ret = caca_get_event($!dp, CACA_EVENT_KEY_PRESS, 0, -1);
    #TODO handle timeout and match return type
    return $ret;
}

method random-color {
    return (Black..White).pick;
}
