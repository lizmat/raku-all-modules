
use v6;
use Test;
use X11::Xlib::Raw;

plan *;

if %*ENV<DISPLAY> {
    lives-ok {
        my $display = XOpenDisplay("") or die "Can't open display %*ENV<DISPLAY>";
        XCloseDisplay($display);
    }, "Can open and close the display";
} else {
    skip "No DISPLAY to test with";
}

done-testing;
