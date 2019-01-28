use v6;
use NativeCall;
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
is gtk_init_check( $argc, CArray[CArray[Str]]), 1, "gtk initalized";

#-------------------------------------------------------------------------------
subtest 'Label create', {

  my GtkLabel $label1 .= new(:text('abc def'));
  isa-ok $label1, GtkLabel;
  isa-ok $label1(), N-GtkWidget;

# direct call has side effects destroying following method like calls
#  is gtk_label_get_text($label1()), 'abc def',
#     'label 1 text ok using native call: gtk_label_get_text';

  is $label1.gtk_label_get_text, 'abc def',
    'label 1 text ok using method $label1.gtk_label_get_text';

  my GtkLabel $label2 .= new(:text('pqr'));
  is $label2.gtk-label-get-text, 'pqr',
     'label 2 text ok using method $label1.gtk-label-get-text';
  $label1($label2());
  is $label1.get-text, 'pqr',
     'label 1 text replaced using method $label1.get-text';
}

#-------------------------------------------------------------------------------
done-testing;
