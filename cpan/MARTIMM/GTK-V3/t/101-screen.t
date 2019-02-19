use v6;

use GTK::V3::Glib::GObject;
use GTK::V3::Gdk::GdkDisplay;
use GTK::V3::Gdk::GdkScreen;

use Test;

#-------------------------------------------------------------------------------
subtest 'Manage display', {
  my GTK::V3::Gdk::GdkScreen $screen;
  throws-like
    { $screen .= new; },
    X::GTK::V3, "No options used",
    :message('No options used to create or set the native widget');

  throws-like
    { $screen .= new( :find, :search); },
    X::GTK::V3, "Wrong options used",
    :message(
      /:s Unsupported options for
          'GTK::V3::Gdk::GdkScreen:'
          [(find||search) ',']+/
    );

  $screen .= new(:default);
  isa-ok $screen, GTK::V3::Gdk::GdkScreen;
  isa-ok $screen(), N-GObject;

  my GTK::V3::Gdk::GdkDisplay $display .= new(:widget($screen.get-display));
  my Str $display-name = $display.get-name();
  like $display-name, /\: \d+/, 'name has proper format: ' ~ $display-name;
#note "DN: $display-name";
}

#-------------------------------------------------------------------------------
done-testing;
