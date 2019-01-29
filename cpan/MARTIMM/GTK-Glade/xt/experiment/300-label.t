use v6;
use NativeCall;
use GUI;
use GtkMain;
use GtkWidget;
use GtkLabel;
use Test;

diag "\n";

# initialize
my GtkMain $main .= new;

# check with default args
my $argc = CArray[int32].new;
$argc[0] = 0;
is $main.gtk-init-check( $argc, CArray[CArray[Str]]), 1, "gtk initalized";

#-------------------------------------------------------------------------------
subtest 'Label create', {

  my GtkLabel $label1 .= new(:text('abc def'));
  isa-ok $label1, GtkLabel;
  does-ok $label1, GUI;
  isa-ok $label1(), N-GtkWidget;

  throws-like
    { $label1.get_nonvisible(); },
    Exception, "non existent sub called",
    :message("Could not find native sub 'get_nonvisible\(...\)'");

  is $label1.get_visible, 0, "widget is invisible";
  $label1.gtk_widget_set-visible(True);
  is $label1.get-visible, 1, "widget set visible";

  is $label1.gtk_label_get_text, 'abc def',
    'label 1 text ok, read with $label1.gtk_label_get_text';

  my GtkLabel $label2 .= new(:text('pqr'));
  is $label2.gtk-label-get-text, 'pqr',
     'label 2 text o, read with $label1.gtk-label-get-text';
  $label1($label2());
  is $label1.get-text, 'pqr',
     'label 1 text replaced, read with $label1.get-text';
}

#-------------------------------------------------------------------------------
done-testing;
