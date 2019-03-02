use v6;
use NativeCall;
use Test;

use GTK::V3::Glib::GObject;
use GTK::V3::Glib::GList;
use GTK::V3::Glib::GMain;
use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkWidget;
use GTK::V3::Gtk::GtkBin;
use GTK::V3::Gtk::GtkButton;
use GTK::V3::Gtk::GtkContainer;
use GTK::V3::Gtk::GtkLabel;

#-------------------------------------------------------------------------------
subtest 'Button create', {

  my GTK::V3::Gtk::GtkButton $button1 .= new(:label('abc def'));
  isa-ok $button1, GTK::V3::Gtk::GtkButton;
  isa-ok $button1, GTK::V3::Gtk::GtkBin;
  isa-ok $button1, GTK::V3::Gtk::GtkContainer;
  isa-ok $button1, GTK::V3::Gtk::GtkWidget;
  #does-ok $button1, GTK::V3::Gui;
  isa-ok $button1(), N-GObject;

  throws-like
    { $button1.get-label('xyz'); },
    X::GTK::V3, "wrong arguments",
    :message('Calling gtk_button_get_label(GTK::V3::Glib::GObject::N-GObject, Str) will never work with declared signature (GTK::V3::Glib::GObject::N-GObject $widget --> Str)');

  is $button1.get-label, 'abc def', 'text on button ok';
  $button1.set-label('xyz');
  is $button1.get-label, 'xyz', 'text on button changed ok';
#`{{
  my GTK::V3::Gtk::GtkButton $b2;
  throws-like
    { $b2 .= new(:widget($button1)) },
    X::GTK::V3, "Wrong type for init",
    :message('Wrong type or undefined widget, must be type N-GObject');

  $b2 .= new(:widget($button1()));
note "B2: $b2, $b2()";
  ok ?$b2, 'button b2 defined';
  is $b2.get-label, 'xyz', 'text on button b2 ok';
}}
}

#-------------------------------------------------------------------------------
subtest 'Button as container', {
  my GTK::V3::Gtk::GtkButton $button1 .= new(:label('xyz'));
  my GTK::V3::Gtk::GtkLabel $l .= new(:label(''));

  my GTK::V3::Glib::GList $gl .= new(:glist($button1.get-children));
  $l($gl.nth-data-gobject(0));
  is $l.get-text, 'xyz', 'text label from button 1';

  my GTK::V3::Gtk::GtkLabel $label .= new(:label('pqr'));
  my GTK::V3::Gtk::GtkButton $button2 .= new(:empty);
  $button2.gtk-container-add($label);

  $l($button2.get-child);
  is $l.get-text, 'pqr', 'text label from button 2';

  # Next statement is not able to get the text directly
  # when gtk-container-add is used.
  is $button2.get-label, Str, 'text cannot be returned like this anymore';

  $gl.g-list-free;
  $gl = GTK::V3::Glib::GList;
}

#-------------------------------------------------------------------------------
class X is GTK::V3::Gtk::GtkButton {

  method click-handler ( :widget($button), Array :$user-data ) {
    isa-ok $button, GTK::V3::Gtk::GtkButton;
    is $user-data[0], 'Hello', 'data 0 ok';
    is $user-data[1], 'World', 'data 1 ok';
  }
}

#-------------------------------------------------------------------------------
subtest 'Button connect and emit signal', {

  # register button signal
  my GTK::V3::Gtk::GtkButton $button .= new(:label('xyz'));
  my Array $data = [];
  $data[0] = 'Hello';
  $data[1] = 'World';

  my X $x .= new(:empty);
  $button.register-signal( $x, 'click-handler', 'clicked', :user-data($data));

  my Promise $p = start {
    # wait for loop to start
    sleep(1.1);

    is $main.gtk-main-level, 1, "loop level now 1";

    my GTK::V3::Glib::GMain $gmain .= new;
    my $main-context = $gmain.context-get-thread-default;

    $gmain.context-invoke(
      $main-context,
      -> $d {
        $button.emit-by-name-wd( 'clicked', $button(), OpaquePointer);

        sleep(1.0);
        $main.gtk-main-quit;

        0
      },
      OpaquePointer
    );

    'test done'
  }

  is $main.gtk-main-level, 0, "loop level 0";
  $main.gtk-main;
  is $main.gtk-main-level, 0, "loop level is 0 again";
}

#-------------------------------------------------------------------------------
done-testing;
