use v6;

use GTK::V3::Glib::GObject;
use GTK::V3::Gdk::GdkDisplay;

use Test;

#-------------------------------------------------------------------------------
subtest 'Manage display', {
  my GTK::V3::Gdk::GdkDisplay $display;
  throws-like
    { $display .= new; },
    X::GTK::V3, "No options used",
    :message('No options used to create or set the native widget');

  throws-like
    { $display .= new( :find, :search); },
    X::GTK::V3, "Wrong options used",
    :message(
      /:s Unsupported options for
          'GTK::V3::Gdk::GdkDisplay:'
          [(find||search) ',']+/
    );

  $display .= new(:default);
  isa-ok $display, GTK::V3::Gdk::GdkDisplay;
  isa-ok $display(), N-GObject;

  my Str $display-name = $display.get-name();
  like $display-name, /\: \d+/, 'name has proper format: ' ~ $display-name;
}

#-------------------------------------------------------------------------------
done-testing;
