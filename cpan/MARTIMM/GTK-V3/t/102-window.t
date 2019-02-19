use v6;

use GTK::V3::Glib::GObject;
#use GTK::V3::Gdk::GdkDisplay;
use GTK::V3::Gdk::GdkWindow;

use Test;

#-------------------------------------------------------------------------------
subtest 'Manage window', {
  my GTK::V3::Gdk::GdkWindow $window;
  throws-like
    { $window .= new; },
    X::GTK::V3, "No options used",
    :message('No options used to create or set the native widget');

  throws-like
    { $window .= new( :find, :search); },
    X::GTK::V3, "Wrong options used",
    :message(
      /:s Unsupported options for
          'GTK::V3::Gdk::GdkWindow:'
          [(find||search) ',']+/
    );

  $window .= new(:default);
  isa-ok $window, GTK::V3::Gdk::GdkWindow;
  isa-ok $window(), N-GObject;

  my Int $wtype = $window.get-window-type;
  is GdkWindowType($wtype), GDK_WINDOW_ROOT, 'root window type';
}

#-------------------------------------------------------------------------------
done-testing;
