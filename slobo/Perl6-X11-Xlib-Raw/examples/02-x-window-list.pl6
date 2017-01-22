use X11::Xlib::Raw;

use NativeCall;
use NativeHelpers::Pointer;

# Taken from https://github.com/patrickhaller/no-wm/blob/master/x-window-list.c

# Shows a simple window-list. Note that if you are
# running a compositing WM, most windows will not show up in the list
# Provide and list index as first argument to have that window come to front
sub MAIN($raise_window_num?){
  my $display = XOpenDisplay("") or die 'Cannot open display';
  my $wins := Pointer[Window].new;

  XQueryTree($display, $display.DefaultRootWindow, my Window $root, my Window $parent, $wins, my uint32 $nwins);

  my XWindowAttributes $attr .= new;

  my @visible_windows = gather for 0..^$nwins -> $i {
    my $w = ($wins + $i).deref;
    XGetWindowAttributes($display, $w, $attr);
    take $w if $attr.map_state == IsViewable;
  }

  my XTextProperty $name .= new;
  my XClassHint $hint .= new;

  for @visible_windows.reverse.kv -> $i, $w {
    my $res_name = XGetClassHint($display, $w, $hint) ?? $hint.res_name !! '<>';
    my $wm_name  = XGetWMName($display, $w, $name)    ?? $name.value    !! '<>';
    note sprintf("%02d 0x%-12x %s - %s", $i, $w, $res_name, $wm_name);

    if $raise_window_num && $raise_window_num == $i  {
      XRaiseWindow($display, $w);
      XSetInputFocus($display, $w, RevertToPointerRoot, CurrentTime);
    }
  }
}
