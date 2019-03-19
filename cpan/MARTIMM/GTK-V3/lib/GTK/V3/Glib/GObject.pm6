use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::N::N-GObject;
use GTK::V3::Gtk::GtkMain;
use GTK::V3::Glib::GSignal;
use GTK::V3::Glib::GValue;

sub EXPORT { {
    'N-GObject' => N-GObject,
  }
};

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
unit class GTK::V3::Glib::GObject:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub g_object_unref ( N-GObject $object )
  is native(&gobject-lib)
  { * }

sub g_object_set_property (
  N-GObject $object, Str $property_name, N-GValue $value
) is native(&gobject-lib)
  { * }

sub g_object_get_property (
  N-GObject $object, Str $property_name, N-GValue $gvalue is rw
) is native(&gobject-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
our $gobject-debug = False; # Type Bool;

has N-GObject $!g-object;
has GTK::V3::Glib::GSignal $!g-signal;

# type is GTK::V3::Gtk::GtkBuilder. Cannot load module because of circular dep.
# attribute is set by GtkBuilder via set-builder(). There might be more than one
my Array $builders = [];

#-------------------------------------------------------------------------------
#TODO destroy when overwritten?
method CALL-ME ( N-GObject $widget? --> N-GObject ) {

  if ?$widget {
    $!g-object = $widget;
  }

  $!g-object
}

#-------------------------------------------------------------------------------
# Fallback method to find the native subs which then can be called as if it
# were a method. Each class must provide their own 'fallback' method which,
# when nothing found, must call the parents fallback with 'callsame'.
# The subs in some class all start with some prefix which can be left out too
# provided that the fallback functions must also test with an added prefix.
# So e.g. a sub 'gtk_label_get_text' defined in class GtlLabel can be called
# like '$label.gtk_label_get_text()' or '$label.get_text()'. As an extra
# feature dashes can be used instead of underscores, so '$label.get-text()'
# works too.
method FALLBACK ( $native-sub is copy, |c ) {

  CATCH { test-catch-exception( $_, $native-sub); }

  # convert all dashes to underscores if there are any. then check if
  # name is not too short.
  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');
  die X::GTK::V3.new(:message(
      "Native sub name '$native-sub' made too short. Keep atleast one '-' or '_'."
    )
  ) unless $native-sub.index('_');

  # check if there are underscores in the name. then the name is not too short.
  my Callable $s;

  # call the fallback functions of this classes children starting
  # at the bottom
  $s = self.fallback($native-sub);

  die X::GTK::V3.new(:message("Native sub '$native-sub' not found"))
      unless $s.defined;
#  unless $s.defined {
#    note "Native sub '$native-sub' not found";
#    return;
#  }

  # User convenience substitutions to get a native object instead of
  # a GtkSomeThing or GlibSomeThing object
  my Array $params = [];
  for c.list -> $p {
    if $p.^name ~~ m/^ 'GTK::V3::' [ Gtk || Gdk || Glib ] '::' / {
      $params.push($p());
    }

    else {
      $params.push($p);
    }
  }

  #note "\ntest-call of $native-sub: ", $s.gist, ', ', $!g-object, ', ', |c.gist
  #  if $gobject-debug;
  test-call( $s, $!g-object, |$params)
}

#-------------------------------------------------------------------------------
method fallback ( $native-sub --> Callable ) {

  my Callable $s;

  try { $s = &::($native-sub); }
  try { $s = &::("g_object_$native-sub"); } unless ?$s;

  # Try to solve sub names from the GSignal class
  unless ?$s {
    $!g-signal .= new(:$!g-object);
    note "GSignal look for $native-sub: ", $!g-signal if $gobject-debug;

    $s = $!g-signal.FALLBACK( $native-sub, :return-sub-only);
  }

  $s = callsame unless ?$s;

  $s
}

#-------------------------------------------------------------------------------
submethod BUILD ( *%options ) {

  note "\nGObject: {self}, ", %options if $gobject-debug;

  # Test if GTK is initialized
  my GTK::V3::Gtk::GtkMain $main .= new;

  if ? %options<widget> {
    note "GObject widget: ", %options<widget> if $gobject-debug;
    my $w = %options<widget>;
    $w = $w() if $w ~~ GTK::V3::Glib::GObject;
    note "go widget converted: ", $w if $gobject-debug;
    if $w ~~ N-GObject {
      note "go widget stored" if $gobject-debug;
      $!g-object = $w;
    }

    else {
      note "Wrong type or undefined widget" if $gobject-debug;
      die X::GTK::V3.new(:message('Wrong type or undefined widget'));
    }
  }

  elsif ? %options<build-id> {
    my N-GObject $widget;
    note "GObject build-id: %options<build-id>" if $gobject-debug;
    for @$builders -> $builder {
      $widget = $builder.get-object(%options<build-id>);
      last if ?$widget;
    }

    if ? $widget {
      note "store widget: ", self.^name, ', ', $widget if $gobject-debug;
      $!g-object = $widget;
    }

    else {
      note "Builder id '%options<build-id>' not found in any of the builders"
        if $gobject-debug;
      die X::GTK::V3.new(
        :message(
          "Builder id '%options<build-id>' not found in any of the builders"
        )
      );
    }
  }

  else {
    if %options.keys.elems == 0 {
      note 'No options used to create or set the native widget'
        if $gobject-debug;
      die X::GTK::V3.new(
        :message('No options used to create or set the native widget')
      );
    }
  }
}

#-------------------------------------------------------------------------------
method debug ( Bool :$on ) {
  $gobject-debug = $on;
  $X::GTK::V3::x-debug = $on;
}

#-------------------------------------------------------------------------------
#TODO destroy when overwritten?
method native-gobject (
  N-GObject $widget?, Bool :$force = False --> N-GObject
) {
  if ?$widget and ( $force or !?$!g-object ) {
    $!g-object = $widget;
  }

  $!g-object
}

#-------------------------------------------------------------------------------
method set-builder ( $builder ) {
  $builders.push($builder);
}

#-------------------------------------------------------------------------------
method register-signal (
  $handler-object, Str:D $handler-name, Str:D $signal-name,
  Int :$connect-flags = 0, Str :$target-widget-name,
  Str :$handler-type where * ~~ any(<wd wwd wsd>) = 'wd',
  *%user-options
  --> Bool
) {

#note $handler-object.^methods;
#note "register $handler-object $handler-name ($handler-type), options: ", %user-options;

  return False unless ?$handler-object && $handler-type ~~ any(<wd wwd wsd>);


  my %options = :widget(self), |%user-options;
  %options<target-widget-name> = $target-widget-name if $target-widget-name;

  my Callable $handler;
  if $handler-type eq 'wd' {
    $handler = -> $w, $d {
      $handler-object.?"$handler-name"( |%options, |%user-options);
    }
  }

  elsif $handler-type eq 'wwd' {
    $handler = -> $w1, $w2, $d {
      $handler-object.?"$handler-name"(
        :widget2($w2), |%options, |%user-options
      );
    }
  }

  else {
    $handler = -> $w, $s, $d {
      $handler-object.?"$handler-name"(
        :string($s), |%options, |%user-options
      );
    }
  }

  $!g-signal .= new(:$!g-object);
  $!g-signal."connect-object-$handler-type"(
    $signal-name, $handler, OpaquePointer, $connect-flags
  );

  True
}

#`{{
#-------------------------------------------------------------------------------
method register-signal (
  $handler-object, Str:D $handler-name, Str:D $signal-name,
  Int :$connect-flags = 0, Str :$target-widget-name,
  Str :$handler-type where * ~~ any(<wd wwd wsd>) = 'wd',
  *%user-options
  --> Bool
) {

#TODO use a hash to set all handler attributes in one go
#note $handler-object.^methods;
#note "register $handler-object $handler-name ($handler-type), options: ", %user-options;

  my Bool $registered-successful = False;

  if ?$handler-object and $handler-object.^can($handler-name) {

    my %options = :widget(self), |%user-options;
    %options<target-widget-name> = $target-widget-name if $target-widget-name;

    if $handler-type eq 'wd' {
      $!g-signal .= new(:$!g-object);

#note "set $handler-name ($handler-type), options: ", %user-options;
      $!g-signal.connect-object-wd(
        $signal-name,
        -> $w, $d {
#note "in callback, calling $handler-name ($handler-type), ", $handler-object;
#note "widget: ", self;
            $handler-object."$handler-name"( |%options, |%user-options);
        },
        OpaquePointer, $connect-flags
      );
    }

    elsif $handler-type eq 'wwd' {
      $!g-signal .= new(:$!g-object);
      $!g-signal.connect-object-wwd(
        $signal-name,
        -> $w1, $w2, $d {
#note "in callback, calling $handler-name ($handler-type), ", $handler-object;
            $handler-object."$handler-name"(
             :widget2($w2), |%options, |%user-options
            );
        },
        OpaquePointer, $connect-flags
      );
    }

    else {
      $!g-signal .= new(:$!g-object);
      $!g-signal.connect-object-wsd(
        $signal-name,
        -> $w, $s, $d {
#note "in callback, calling $handler-name ($handler-type), ", $handler-object;
            $handler-object."$handler-name"(
             :string($s), |%options, |%user-options
            );
        },
        OpaquePointer, $connect-flags
      );
    }

    $registered-successful = True;
  }

#`{{
  elsif ?$handler-object {
    #note "Handler $handler-name on $id object using $signal-name event not defined";
    note "Handler $handler-name not defined in {$handler-object.^name}";

  }

  else {
    note "Handler object is not defined";
#    self.connect-object( 'clicked', $handler, OpaquePointer, $connect_flags);
  }
}}


  $registered-successful
}
}}
