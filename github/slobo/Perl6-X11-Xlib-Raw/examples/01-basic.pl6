use X11::Xlib::Raw;


# Taken from https://en.wikipedia.org/wiki/Xlib#Example
sub MAIN(){
  note '/* open connection with the server */';
  my $display = XOpenDisplay("") or die 'Cannot open display';

  my $s = $display.DefaultScreen();

  note '/* create window */';
  my Window $window = XCreateSimpleWindow($display, $display.RootWindow($s), 10, 10, 200, 200, 1,
    $display.BlackPixel($s), $display.WhitePixel($s)
  );

  note '/* select kind of events we are interested in */';
  XSelectInput($display, $window, ExposureMask +| KeyPressMask);

  note '/* map (show) the window */';
  XMapWindow($display, $window);

  my Str $msg = "Hello, World!";
  my XEvent $event .= new;
  note '/* event loop */';
  loop {
    XNextEvent($display, $event);
    note $event;
    given $event.type {
      when Expose {
        note '/* draw or redraw the window */';
        XFillRectangle($display, $window, $display.DefaultGC($s), 20, 20, 10, 10);
        XDrawString($display, $window, $display.DefaultGC($s), 50, 50, $msg, $msg.chars);
      }
      when KeyPress {
        note '/* exit on key press */';
        last
      }
    }
  };

  note '/* close connection to server */';
  XCloseDisplay($display);
}
