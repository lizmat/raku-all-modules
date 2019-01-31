use v6;
use NativeCall;
use Test;

use GTK::Glade::Gui;
use GTK::V3::Glib::GMain;
use GTK::V3::Gtk::GtkMain;

diag "\nGlib main loop test";

# initialize
my GTK::V3::Gtk::GtkMain $main .= new;

# check with default args
my $argc = CArray[int32].new;
$argc[0] = 0;
is $main.gtk-init-check( $argc, CArray[CArray[Str]]), 1, "gtk initalized";

#-------------------------------------------------------------------------------
my GTK::V3::Glib::GMain $gmain .= new;
my $main-context1 = $gmain.g-main-context-new;
my $loop = $gmain.g-main-loop-new( $main-context1, False);

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
  my $main-context2 = $gmain.g-main-context-new;
  $gmain.g-main-context-push-thread-default($main-context2);

  diag "$*THREAD.id(), " ~
       "Use g-main-context-invoke-full() to invoke sub on thread";

  $gmain.g-main-context-invoke-full(
    $main-context2, G_PRIORITY_DEFAULT, &handler,
    $data, &notify
  );

  'test done'
}

diag "$*THREAD.id(), start loop with g-main-loop-run()";
$gmain.g-main-loop-run($loop);
diag "$*THREAD.id(), loop stopped";

await $p;
is $p.result, 'test done', 'result promise ok';

#-------------------------------------------------------------------------------
done-testing;

#-------------------------------------------------------------------------------
sub handler ( CArray[Str] $h-data ) {

  diag "$*THREAD.id(), In handler on same thread";
  is $h-data[0], 'handler data', 'data[0] ok';
  is $h-data[1], 'some more data', 'data[1] ok';
  diag "$*THREAD.id(), Use g-main-loop-quit() to stop loop";
  $gmain.g-main-loop-quit($loop);

  G_SOURCE_REMOVE
}

#-------------------------------------------------------------------------------
sub notify ( CArray[Str] $h-data ) {
  diag "$*THREAD.id(), In notify handler";
  is $h-data[0], 'handler data', 'data[0] ok';
  is $h-data[1], 'some more data', 'data[1] ok';
}
