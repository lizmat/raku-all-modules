use v6;
use NativeCall;
use Test;

use GTK::Glade::Gui;
use GTK::V3::Glib::GMain;
use GTK::V3::Gtk::GtkMain;

diag "\nGTK main loop test";

# initialize
my GTK::V3::Gtk::GtkMain $main .= new;

#-------------------------------------------------------------------------------
my GTK::V3::Glib::GMain $gmain .= new;

my CArray[Str] $data .= new;
$data[0] = 'handler data';
$data[1] = 'some more data';

diag "$*THREAD.id(), Start thread";
my Promise $p = start {
  # wait for loop to start
  sleep(1.1);

  diag "$*THREAD.id(), Create context to invoke handler on thread";

  # This part is important that it happens in the thread where the
  # function is invoked in that context! The context must be
  # different than the one above to create the loop
  my $main-context = $gmain.g-main-context-new;
  $gmain.g-main-context-push-thread-default($main-context);

  diag "$*THREAD.id(), Use g-main-context-invoke to invoke sub on thread";

  $gmain.g-main-context-invoke(
    $main-context,
    -> $h-data {

      diag "$*THREAD.id(), In handler on same thread";
      is $h-data[0], 'handler data', 'data[0] ok';
      is $h-data[1], 'some more data', 'data[1] ok';

      diag "$*THREAD.id(), Use gtk-main-quit() to stop loop";
      $main.gtk-main-quit;

      0
    },
    $data
  );

  'test done'
}

diag "$*THREAD.id(), start loop with gtk-main()";
$main.gtk-main;
diag "$*THREAD.id(), loop stopped";

await $p;
is $p.result, 'test done', 'result promise ok';

#-------------------------------------------------------------------------------
done-testing;
