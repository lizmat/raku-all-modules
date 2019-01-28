use v6;
use NativeCall;

use XML::Actions;

use GTK::Glade::NativeGtk :ALL;
use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Gdk;
use GTK::Glade::Native::Gtk::Widget;
use GTK::Glade::Native::Gtk::Builder;

use GTK::Glade::Engine;
use GTK::Glade::Engine::Test;
use GTK::Glade::Engine::Work;
use GTK::Glade::Engine::PreProcess;

#`{{
#-------------------------------------------------------------------------------
# Export all symbols and functions from GTK::Simple::Raw
sub EXPORT {
  my %export;
  for GTK::Glade::NativeGtk::EXPORT::ALL::.kv -> $k,$v {
    %export{$k} = $v;
  }

  %export;
}
}}

#-------------------------------------------------------------------------------
class X::GTK::Glade:auth<github:MARTIMM> is Exception {
  has Str $.message;            # Error text and error code are data mostly
#  has Str $.method;             # Method or routine name
#  has Int $.line;               # Line number where Message is called
#  has Str $.file;               # File in which that happened
}

#-------------------------------------------------------------------------------
class GTK::Glade:auth<github:MARTIMM> {

  #-----------------------------------------------------------------------------
  submethod BUILD (
    Str :$ui-file, Str :$css-file, GTK::Glade::Engine:D :$engine,
    GTK::Glade::Engine::Test :$test-setup
  ) {

    die X::GTK::Glade.new(
      :message("No suitable glade XML file: '$ui-file'")
    ) unless ?$ui-file and $ui-file.IO ~~ :r;

note "New ui file $ui-file";


    # Prepare XML document for processing
    my XML::Actions $actions .= new(:file($ui-file));

    # Prepare Gtk Glade work for preprocessing. In this phase all missing
    # ids on objects are generated and written back in the xml elements.
    my GTK::Glade::Engine::PreProcess $pp .= new;
    $actions.process(:actions($pp));
    my Str $modified-ui = $actions.result;
    my Str $toplevel-id = $pp.toplevel-id;
    $pp = GTK::Glade::Engine::PreProcess;

#    "modified-ui.glade".IO.spurt($modified-ui); # test dump for result

    # Prepare Gtk Glade work for processing the glade XML
    my GTK::Glade::Engine::Work $work .= new(:test(?$test-setup));
    $work.glade-add-gui(:ui-string($modified-ui));
#    $work.glade-add-gui(:ui-string("hoeperdepoep")); # test for failure

    # deallocate the glade XML string
    $modified-ui = Str;

    # Process the XML document creating the API to the UI
    $actions.process(:actions($work));

    # Css can be added only after processing is done. There is a toplevel
    # widget needed which is known afterwards.
    $work.glade-add-css(:$css-file);

    # Copy the builder object
    $engine.builder = $work.builder;
    $work.glade-run( :$engine, :$test-setup, :$toplevel-id);

    #note $work.state-engine-data;
  }

#`{{
  #-----------------------------------------------------------------------------
  method !find-glade-file ( Str $ui-file is copy --> Str ) {

    # return if readable
    return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;

    my @tried-list = $ui-file,;

note "Ui file '$ui-file' not found, $*PROGRAM-NAME";

    my Str $program = $*PROGRAM-NAME.IO.basename;
    $program ~~ s/\. <-[\.]>* $/.glade/;
    $ui-file = %?RESOURCES{$program}.Str;
note "Try '$program' from resources";
    return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;
    @tried-list.push("Resources: $program");

    $program ~~ s/\. glade $/.ui/;
    $ui-file = %?RESOURCES{$program}.Str;
note "Try '$program' from resources";
    return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;
    @tried-list.push($program);

    $ui-file = %?RESOURCES{"graphical-interface.glade"}.Str;
note "Try 'graphical-interface.glade' from resources";
    return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;
    @tried-list.push("graphical-interface.glade");


    $program = $*PROGRAM-NAME.IO.basename;
    $program ~~ s/\. <-[\.]>* $//;
    note "Try 'graphical-interface.glade' from config directories $*HOME/.$program or $*HOME/.config/$program";

    if "$*HOME/.$program".IO ~~ :d {
      $ui-file = "$*HOME/.$program/graphical-interface.glade";
note "Try '$ui-file'";
      return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;
      @tried-list.push("Config: $ui-file");
    }

    elsif "$*HOME/.config/$program".IO ~~ :d {
      $ui-file = "$*HOME/.config/$program/graphical-interface.glade";
note "Try '$ui-file'";
      return $ui-file if ?$ui-file and $ui-file.IO ~~ :r;
      @tried-list.push($ui-file);
    }

    die X::GTK::Glade.new(
      :message(
        "No suitable glade XML file found. Tried " ~ @tried-list.join(', ')
      )
    );
  }
}}
}
