use v6;
use NativeCall;
use Test;

use GTK::Glade::Gui;
use GTK::V3::Glib::GMain;
use GTK::V3::Gtk::GtkMain;
#use GTK::V3::Gtk::GtkWidget;
#use GTK::V3::Gtk::GtkLabel;

diag "\n";

# initialize
my GTK::V3::Gtk::GtkMain $main .= new;

# check with default args
my $argc = CArray[int32].new;
$argc[0] = 0;
is $main.gtk-init-check( $argc, CArray[CArray[Str]]), 1, "gtk initalized";

diag "Start thread";
my Promise $p = start {
  sleep(2);

  my $data = 'handler data';
  my GTK::V3::Glib::GMain $gmain .= new;
  diag "Invoke";
  $gmain.g-main-context-invoke(
    Any,
    -> $data {
      diag "In handler";
      is $data, 'handler data', 'data transferred to handler';
      my GTK::V3::Gtk::GtkMain $m .= new;
      $m.gtk-main-quit();

      False
    },
  );

  'test done'
}

diag "start main loop";
$main.gtk-main();

await $p;
#is $p.status, KEEP , 'promise kept';
is $p.result, 'test done', 'result promise ok';

#-------------------------------------------------------------------------------
done-testing;
