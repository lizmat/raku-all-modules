use v6;
use NativeCall;

use XML::Actions;

use GTK::Glade::Engine;
use GTK::Glade::Engine::Test;

use GTK::V3::Glib::GObject;
use GTK::V3::Glib::GSignal;
use GTK::V3::Gdk::GdkScreen;
use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkBuilder;
use GTK::V3::Gtk::GtkCssProvider;
use GTK::V3::Gtk::GtkStyleContext;

# Pick the extremities of modules to get all depending modules.
use GTK::V3::Gtk::GtkImageMenuItem;
use GTK::V3::Gtk::GtkAboutDialog;
use GTK::V3::Gtk::GtkFileChooserDialog;
use GTK::V3::Gtk::GtkRadioButton;
use GTK::V3::Gtk::GtkLabel;
use GTK::V3::Gtk::GtkEntry;

#-------------------------------------------------------------------------------
unit class GTK::Glade::Engine::Work:auth<github:MARTIMM> is XML::Actions::Work;

has GTK::V3::Gdk::GdkScreen $!gdk-screen;
has GTK::V3::Gtk::GtkMain $!main;
has GTK::V3::Gtk::GtkBuilder $.builder;
has GTK::V3::Gtk::GtkCssProvider $!css-provider;
has GTK::V3::Gtk::GtkStyleContext $!style-context;

has Array $!engines;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  # initializing GTK is done in Engine because it lives before Work
  $!main .= new;
  $!gdk-screen .= new(:default);
  $!css-provider .= new(:empty);
  $!style-context .= new(:empty);

  $!engines = [];
}

#-----------------------------------------------------------------------------
method glade-add-engine ( GTK::Glade::Engine:D $engine ) {

#TODO init in BUILD first then add etc
  $!engines.push($engine);
}

#-------------------------------------------------------------------------------
# Prefix all methods with 'glade-' to distinguish them from callback methods
# for glade gui xml elements when that file is processed by XML::Actions
#-------------------------------------------------------------------------------
multi method glade-add-gui ( Str:D :$ui-file! ) {

  if ?$!builder {
    my $error-code = $!builder.gtk_builder_add_from_file( $ui-file, Any);
    die X::GTK::Glade.new(:message("error adding ui")) if $error-code == 0;
  }

  else {
    $!builder .= new(:filename($ui-file));
  }
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
multi method glade-add-gui ( Str:D :$ui-string! ) {

  if ?$!builder {
    my $error-code = $!builder.gtk_builder_add_from_string(
      $ui-string, $ui-string.chars, Any
    );
    die X::GTK::Glade.new(:message("error adding ui")) if $error-code == 0;
  }

  else {
    $!builder .= new(:string($ui-string));
  }
}

#-------------------------------------------------------------------------------
method glade-add-css ( Str:D $css-file ) {

  return unless ?$css-file and $css-file.IO ~~ :r;

#$!css-provider.debug(:on);
  $!css-provider.gtk_css_provider_load_from_path( $css-file, Any);

  $!style-context.gtk_style_context_add_provider_for_screen(
    $!gdk-screen, $!css-provider, GTK_STYLE_PROVIDER_PRIORITY_USER
  );

  #my GtkCssProvider $css-provider = gtk_css_provider_get_named(
  #  'Kate', Any
  #);
}

#-------------------------------------------------------------------------------
method glade-run (
  GTK::Glade::Engine::Test :$test-setup,
  #Str :$toplevel-id
) {

#  gtk_widget_show_all(gtk_builder_get_object( $!builder, $toplevel-id));

  if $test-setup.defined {

    # copy builder object to test object
    $test-setup.builder = $!builder;
    $test-setup.prepare-and-run-tests;
  }

  else {

note "Start loop";
    $!main.gtk_main();
  }
}

#-------------------------------------------------------------------------------
# Callback methods called from XML::Actions
#-------------------------------------------------------------------------------
#`{{}}
method object ( Array:D $parent-path, Str :$id is copy, Str :$class) {

#  note "Object $class, id '$id'";

#  return unless $class eq "GtkWindow";
#  $!top-level-object-id = $id unless ?$!top-level-object-id;
}


#-------------------------------------------------------------------------------
# signal element, e.g.
#   <signal name="clicked" handler="clear-text" swapped="no"/>
# possible attributes are: name, handler, object, after and swapped
method signal (
  Array:D $parent-path, Str:D :name($signal-name),
  Str:D :handler($handler-name),
  Str :$object, Str :$after, Str :$swapped
) {
  #TODO bring following code into XML::Actions
  my %object = $parent-path[*-2].attribs;
  my Str $id = %object<id>;
  my Str $class = %object<class>;
  my Str $class-name = 'GTK::V3::Gtk::' ~ $class;
  my Bool $handler-found = False;
#note "\nId and class: $id, $class, $class-name";
#note "P: ", GTK::V3::Gtk::.keys;

  my Int $connect-flags = 0;
  $connect-flags +|= G_CONNECT_SWAPPED if ($swapped//'') eq 'yes';
  $connect-flags +|= G_CONNECT_AFTER if ($after//'') eq 'yes';

  for @$!engines -> $engine {
#note GTK::V3::Gtk::{$class};
    if GTK::V3::Gtk::{$class}:exists {

#note ::("GTK::V3::Gtk::$class").Bool;
      my $gtk-widget = ::($class-name).new(:build-id($id));
#  note "v3 gtk obj: ", $gtk-widget;

      if $gtk-widget.register-signal(
        $engine, $handler-name, $signal-name, :$connect-flags,
        :target-widget-name($object), :handler-type<wd>
      ) {
        $handler-found = True;
        last;
      }
    }

    else {
      try {
#note "require $class-name";
#      require ::('GTK::V3::Gtk');
        require ::($class-name);
#note "P2: ", GTK::V3::Gtk::.keys;

#note ::("GTK::V3::Gtk::$class").Bool;
        my $gtk-widget = ::($class-name).new(:build-id($id));
#  note "v3 gtk obj: ", $gtk-widget;

        if $gtk-widget.register-signal(
          $engine, $handler-name, $signal-name, :$connect-flags,
          :target-widget-name($object), :handler-type<wd>
        ) {
          $handler-found = True;
          last;
        }

        CATCH {
#.note;
          default {
            note "Not able to load module: ", .message;
          }
        }
      }
    }
  }

  note "Handler $handler-name not defined in any engine" unless $handler-found;
}

#-------------------------------------------------------------------------------
# Private methods
#-------------------------------------------------------------------------------
#method !glade-parsing-error( $provider, $section, $error, $pointer ) {
#  note "Error";
#}
