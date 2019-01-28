use v6;

use XML::Actions;

#-------------------------------------------------------------------------------
# Preprocessing class to get ids on all objects
unit class GTK::Glade::Engine::PreProcess:auth<github:MARTIMM>
           is XML::Actions::Work;


has Str $!default-id = "gtk-glade-id-0001";
has $.toplevel-id;

method object ( Array:D $parent-path, Str :$id is copy, Str :$class) {

  # if no id is defined, modify the xml element
  if !? $id {
    $id = $!default-id;
    $parent-path[*-1].set( 'id', $!default-id);
    $!default-id .= succ;
  }

  if $class eq 'GtkWindow' {
    $!toplevel-id = $id unless ?$!toplevel-id;
  }
}
