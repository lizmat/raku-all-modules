use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::Glade

=SUBTITLE

  unit Gtk::Glade;

=head1 Synopsis

  use MyGui::MainEngine;
  use MyGui::SecondEngine;
  use GTK::Glade;

  sub MAIN ( Str:D $glade-xml-file ) {
    my GTK::Glade $gui .= new;
    $gui.add-gui-file($glade-xml-file);
    $gui.add-engine(MyGui::MainEngine.new);
    $gui.add-engine(MyGui::SecondEngine.new);
    $gui.run;
  }

=end pod
# ==============================================================================
use NativeCall;

use XML::Actions;

use GTK::Glade::X;
use GTK::Glade::Engine;
use GTK::Glade::Engine::Test;
use GTK::Glade::Engine::Work;
use GTK::Glade::Engine::PreProcess;

#-------------------------------------------------------------------------------
unit class GTK::Glade:auth<github:MARTIMM>;

has Str $!modified-ui;
has GTK::Glade::Engine::Work $!work;
has XML::Actions $!actions;

#-------------------------------------------------------------------------------
=begin pod
=head2 new

  submethod BUILD ( )

Initialize Glade interface.
=end pod
submethod BUILD ( ) {

  $!work .= new;
}

#-------------------------------------------------------------------------------
=begin pod
=head2 add-gui-file

  method add-gui-file ( Str $ui-file )

Add an XML document saved by the glade user interface designer.
=end pod
method add-gui-file ( Str:D $ui-file where .IO ~~ :r ) {

  # Prepare XML document for processing
  $!actions .= new(:file($ui-file));

  # Prepare Gtk Glade work for preprocessing. In this phase all missing
  # ids on objects are generated and written back in the xml elements.
  my GTK::Glade::Engine::PreProcess $pp .= new;
  $!actions.process(:actions($pp));
  $!modified-ui = $!actions.result;

  $!work.glade-add-gui(:ui-string($!modified-ui));
}

#-------------------------------------------------------------------------------
=begin pod
=head2 add-engine

  method add-engine ( GTK::Glade::Engine $engine )

Add the user object where callback methods are defined.
=end pod
method add-engine ( GTK::Glade::Engine:D $engine ) {

  $!work.glade-add-engine($engine);
}

#-------------------------------------------------------------------------------
=begin pod
=head2 add-css

  method add-css ( Str $css-file )

Add a css style file, This is a CSS-like input in order to style widgets. Classes and id's are definable in the glade interface designer. A few are reserved. You need to look up the documents for a particular widget to find that out. E.g. the button knows about the C<circular> and C<flat> classes (See also L<gnome developer docs|https://developer.gnome.org/gtk3/stable/GtkButton.html> section CSS nodes).
=end pod
method add-css ( Str:D $css-file where .IO ~~ :r ) {

  # Css can be added only after processing is done. There is a toplevel
  # widget needed which is known afterwards.
  $!work.glade-add-css($css-file);
}

#-------------------------------------------------------------------------------
=begin pod
=head2 run

  method run ( )

Run the glade design. It will enter the main loop and when interacting with the interface, events will call the callbacks defined in one of the added engines.
=end pod
method run ( GTK::Glade::Engine::Test :$test-setup ) {

  # Process the XML document creating the API to the UI
  $!actions.process(:actions($!work));

  # show user design and run main loop
  $!work.glade-run(:$test-setup);
}
