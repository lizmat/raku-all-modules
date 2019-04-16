use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Glib::GObject

=SUBTITLE

  unit class GTK::V3::Glib::GObject;

=head2 GObject — The base object type

=head1 Synopsis

Top level class of almost all classes in the GTK, GDK and Glib libraries.

This object is almost never used directly. Most of the classes inherit from this class. The below example can be made much simpler by setting the label directly in the init of C<GtKLabel>. The purpose of this example, however, is that there are other properties which can only be set this way. Also not all types are covered yet by C<GValue> and C<GType>.

  use GTK::V3::Glib::GObject;
  use GTK::V3::Glib::GValue;
  use GTK::V3::Glib::GType;
  use GTK::V3::Gtk::GtkLabel;

  my GTK::V3::Glib::GType $gt .= new;
  my GTK::V3::Glib::GValue $gv .= new(:init(G_TYPE_STRING));

  my GTK::V3::Gtk::GtkLabel $label1 .= new(:label(''));
  $gv.g-value-set-string('label string');
  $label1.g-object-set-property( 'label', $gv);

=end pod
# ==============================================================================
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

# ==============================================================================
#`{{
=begin pod

=head1 Methods

=head2 g_object_ref

  method g_object_ref ( )

Increases the reference count of $object. The new() methods will increase the reference count of the native object automatically and when destroyed or overwritten decreased.

=end pod
}}
sub g_object_ref ( N-GObject $object )
  returns N-GObject
  is native(&gobject-lib)
  { * }

# ==============================================================================
#`{{
=begin pod

=head2 g_object_unref

  method g_object_unref ( )

Decreases the reference count of object. When its reference count drops to 0, the object is finalized (i.e. its memory is freed). The widget classes will automatically decrease the reference count to the native object when destroyed or when overwritten.

=end pod
}}
sub g_object_unref ( N-GObject $object )
  is native(&gobject-lib)
  { * }

# ==============================================================================
#`{{
=begin pod

=head2 [g_object_] ref_sink

  method g_object_ref_sink ( )

Increase the reference count of object , and possibly remove the floating reference. See also L<gtk developer docs|https://developer.gnome.org/gobject/unstable/gobject-The-Base-Object-Type.html#g-object-ref-sink>.
=end pod
}}
sub g_object_ref_sink ( N-GObject $object )
  is native(&gobject-lib)
  { * }

# ==============================================================================
#`{{
=begin pod

=head2 g_clear_object

  method g_clear_object ( )

Clears a reference to a GObject. The reference count of the object is decreased and the pointer is set to NULL.
=end pod
}}
sub g_clear_object ( N-GObject $object is rw ) {
  hidden_g_clear_object(N-GObject $object);
  #GOBject.g_object_unref($object)
  $object = N-GObject;
}
sub hidden_g_clear_object ( N-GObject $object is rw )
  is native(&gobject-lib)
  is symbol('g_clear_object')
  { * }

# ==============================================================================
#`{{
=begin pod

=head2 [g_object_] is_floating

  method g_object_is_floating ( )

Checks whether object has a floating reference.
=end pod
}}
sub g_object_is_floating ( N-GObject $object )
  returns int32
  is native(&gobject-lib)
  { * }

# ==============================================================================
#`{{
=begin pod

=head2 [g_object_] force_floating

  method g_object_force_floating ( )

=end pod
}}
sub g_object_force_floating ( N-GObject $object )
  is native(&gobject-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [g_object_] set_property

  method g_object_set_property (
    Str $property_name, GTK::V3::Glib::GValue $value
  )

Sets a property on an object.
=end pod
sub g_object_set_property (
  N-GObject $object, Str $property_name, N-GValue $value
) is native(&gobject-lib)
  { * }

# ==============================================================================
=begin pod
=head2 [g_object_] get_property

  method g_object_get_property (
    Str $property_name, GTK::V3::Glib::GValue $value is rw
  )

Gets a property of an object. value must have been initialized to the expected type of the property (or a type to which the expected type can be transformed) using g_value_init().

In general, a copy is made of the property contents and the caller is responsible for freeing the memory by calling g_value_unset().
=end pod
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
#`{{
=begin pod
=head2 CALL-ME

  method CALL-ME ( N-GObject $widget? --> N-GObject )

This method is designed to set and retrieve the gtk object from a perl6 widget object. This is indirectly called by C<new> when the :widget option is used. On many occasions this is done automatically or indirect like explained above, that it is hardly used by the user directly.

  # Example only to show how things can be tranported between objects. Not
  # something you need to remember!
  my N-GObject $button = GTK::V3::Gtk::GtkButton.new(:label('Exit'))();
  my GTK::V3::Gtk::GtkButton $b .= new(:empty);
  $b($button);

See also L<native-gobject>.
=end pod
}}
#TODO destroy when overwritten? g_object_unref?
method CALL-ME ( N-GObject $widget? --> N-GObject ) {

  if ?$widget {
    # if native object exists it will be overwritten. unref object first.
    if ?$!g-object {
      #TODO self.g_object_unref();
    }
    $!g-object = $widget;
    #TODO self.g_object_ref();
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
=begin pod
=head2 new

=head3  multi submethod BUILD ( :$widget )

Create a Perl6 widget object using a native widget from elsewhere. $widget can be a N-GOBject or a Perl6 widget like C< GTK::V3::Gtk::GtkButton>.

  # some set of radio buttons grouped together
  my GTK::V3::Gtk::GtkRadioButton $rb1 .= new(:label('Download everything'));
  my GTK::V3::Gtk::GtkRadioButton $rb2 .= new(
    :group-from($rb1), :label('Download core only')
  );

  # get all radio buttons of group of button $rb2
  my GTK::V3::Glib::GSList $rb-list .= new(:gslist($rb2.get-group));
  loop ( Int $i = 0; $i < $rb-list.g_slist_length; $i++ ) {
    # get button from the list
    my GTK::V3::Gtk::GtkRadioButton $rb .= new(
      :widget($rb-list.nth-data-gobject($i))
    );

    if $rb.get-active == 1 {
      # execute task for this radio button

      last;
    }
  }

Another example is a difficult way to get a button.

  my GTK::V3::Gtk::GtkButton $start-button .= new(
    :widget(GTK::V3::Gtk::GtkButton.gtk_button_new_with_label('Start'))
  );

=head3  multi submethod BUILD ( Str :$build-id )

Create a Perl6 widget object using a C<GtkBuilder>. The C<GtkBuilder> class will handover its object address to the C<GObject> and can then be used to search for id's defined in the GUI glade design.

  my GTK::V3::Gtk::GtkBuilder $builder .= new(:filename<my-gui.glade>);
  my GTK::V3::Gtk::GtkButton $button .= new(:build-id<my-gui-button>);

=end pod

submethod BUILD ( *%options ) {

  note "\ngobject: {self}, ", %options if $gobject-debug;

  # Test if GTK is initialized
  my GTK::V3::Gtk::GtkMain $main .= new;

  if ? %options<widget> {
    note "gobject widget: ", %options<widget> if $gobject-debug;
    my $w = %options<widget>;
    $w = $w() if $w ~~ GTK::V3::Glib::GObject;
    note "gobject widget converted: ", $w if $gobject-debug;
    if $w ~~ N-GObject {
      note "gobject widget stored" if $gobject-debug;
      $!g-object = $w;
    }

    else {
      note "wrong type or undefined widget" if $gobject-debug;
      die X::GTK::V3.new(:message('Wrong type or undefined widget'));
    }
  }

  elsif ? %options<build-id> {
    my N-GObject $widget;
    note "gobject build-id: %options<build-id>" if $gobject-debug;
    for @$builders -> $builder {
      # this action does not increase object refcount, do it here.
      $widget = $builder.get-object(%options<build-id>);
      #TODO self.g_object_ref();
      last if ?$widget;
    }

    if ? $widget {
      note "store gobject widget: ", self.^name, ', ', $widget
        if $gobject-debug;
      $!g-object = $widget;
    }

    else {
      note "builder id '%options<build-id>' not found in any of the builders"
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

  #TODO if %options<id> add id, %options<name> add name
  #cannot add id,seems to be a builder thing.
}

#-------------------------------------------------------------------------------
=begin pod
=head2 debug

  method debug ( Bool :$on )

There are many situations when exceptions are retrown within code of a callback method, Perl6 is not able to display the error properly (yet). In those cases you need another way to display errors and show extra messages leading up to it.
=end pod

method debug ( Bool :$on ) {
  $gobject-debug = $on;
  $X::GTK::V3::x-debug = $on;
}

#-------------------------------------------------------------------------------
#`{{
=begin pod
=head2 native-gobject

  method native-gobject (
    N-GObject $widget?, Bool :$force = False --> N-GObject
  )

This method has the same purpose as C<CALL-ME> explained above. Here, however, it will not automatically overwrite a native object when there is already one there. Use C<:force> to get the same effect. It will always return a native object.
=end pod
}}
#TODO destroy when overwritten?
method native-gobject (
  N-GObject $widget?, Bool :$force = False --> N-GObject
) {
  if ?$widget and ( $force or !?$!g-object ) {
    if ?$!g-object {
      #TODO self.g_object_unref();
    }
    $!g-object = $widget;
    #TODO self.g_object_ref();
  }

  $!g-object
}

#-------------------------------------------------------------------------------
method set-builder ( $builder ) {
  $builders.push($builder);
}

#-------------------------------------------------------------------------------
=begin pod
=head2 register-signal

  method register-signal (
    $handler-object, Str:D $handler-name, Str:D $signal-name,
    Str :$handler-type where * ~~ any(<wd wwd wsd>) = 'wd',
    Int :$connect-flags = 0, *%user-options
    --> Bool
  )

Register a handler to process a signal event.

=item $handler-object is the object wherein the handler is defined.
=item $handler-name is name of the method.
=item $signal-name is the name of the event to be handled. Each gtk widget has its own series of signals, please look for it in the documentation of gtk.
=item $connect-flags can be on of C<G_CONNECT_AFTER> or C<G_CONNECT_SWAPPED>. See L<documentation here|https://developer.gnome.org/gobject/stable/gobject-Signals.html#GConnectFlags>.
=item $handler-type is by default 'wd' to use C<g_signal_connect_wd> from L<GSignal>. Other types are not yet defined.
=item %user-options. Any other user data in whatever type. These arguments are provided to the user handler when an event for the handler is fired. There will always be one named argument C<:$widget> which holds the class object on which the signal was registered. The name 'widget' is therefore reserved.


  # create a class holding a handler method to process a click event
  # of a button.
  class X {
    method click-handler ( :widget($button), Array :$user-data ) {
      say $user-data.join(' ');
    }
  }

  # create a button and some data to send with the signal
  my GTK::V3::Gtk::GtkButton $button .= new(:label('xyz'));
  my Array $data = [<Hello World>];

  # register button signal
  my X $x .= new(:empty);
  $button.register-signal( $x, 'click-handler', 'clicked', :user-data($data));

=end pod
method register-signal (
  $handler-object, Str:D $handler-name, Str:D $signal-name,
  Int :$connect-flags = 0,
  #Int :$connect-flags = 0, Str :$target-widget-name,
  Str :$handler-type where * ~~ any(<wd wwd wsd>) = 'wd',
  *%user-options
  --> Bool
) {

#note $handler-object.^methods;
#note "register $handler-object $handler-name ($handler-type), options: ", %user-options;

  return False unless ?$handler-object && $handler-type ~~ any(<wd wwd wsd>);


  my %options = :widget(self), |%user-options;
  #%options<target-widget-name> = $target-widget-name if $target-widget-name;

  my Callable $handler;
  if $handler-type eq 'wd' {
    $handler = -> $w, $d {
      $handler-object.?"$handler-name"(|%options);
      #$handler-object.?"$handler-name"( |%options, |%user-options);
    }
  }

  elsif $handler-type eq 'wwd' {
    $handler = -> $w1, $w2, $d {
      $handler-object.?"$handler-name"(
        :widget2($w2), |%options
        #:widget2($w2), |%options, |%user-options
      );
    }
  }

  else {
    $handler = -> $w, $s, $d {
      $handler-object.?"$handler-name"(
        :string($s), |%options
        #:string($s), |%options, |%user-options
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
