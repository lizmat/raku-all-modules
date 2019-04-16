use v6;
# ==============================================================================
=begin pod

=TITLE class GTK::V3::Gdk::GdkEvent

=SUBTITLE


=head2 Event Structures — Data structures specific to each type of event

#TODO must provide different args to handler call depending on handler
=head1 Synopsis

  my GTK::V3::Gtk::GtkWindow $top-window .= new(:empty);
  $top-window.set-title('Hello GTK!');
  # ... etcetera ...

  # Register a signal handler for a window event
  $top-window.register-signal( self, 'handle-keypress', 'key-press-event');

  method handle-keypress ( :$widget, GdkEvent :$event ) {
    if $event.event-any.type ~~ GDK_KEY_PRESS and
       $event.event-key.keyval eq 's' {

      # key 's' pressed, stop process ...
    }
  }

The handler signature can also be defined as

  method handle-keypress ( :$widget, GdkEventKey :$event ) {
    if $event.type ~~ GDK_KEY_PRESS and $event.keyval eq 's' {

      # key 's' pressed, stop process ...
    }
  }


=end pod
# ==============================================================================
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Gdk::GdkWindow;
use GTK::V3::Gdk::GdkDevice;

# ==============================================================================
# https://developer.gnome.org/gdk3/stable/gdk3-Event-Structures.html
# https://developer.gnome.org/gdk3/stable/gdk3-Events.html
#unit class GTK::V3::Gdk::GdkEvent:auth<github:MARTIMM>;

# ==============================================================================
=begin pod
=head1 Enums, Structs and Unions

=head2 Enum GdkEventType
Specifies the type of the event.

Do not confuse these events with the signals that GTK+ widgets emit. Although many of these events result in corresponding signals being emitted, the events are often transformed or filtered along the way.

In some language bindings, the values GDK_2BUTTON_PRESS and GDK_3BUTTON_PRESS would translate into something syntactically invalid (eg Gdk.EventType.2ButtonPress, where a symbol is not allowed to start with a number). In that case, the aliases GDK_DOUBLE_BUTTON_PRESS and GDK_TRIPLE_BUTTON_PRESS can be used instead.

=item GDK_NOTHING; a special code to indicate a null event.
=item GDK_DELETE; the window manager has requested that the toplevel window be hidden or destroyed, usually when the user clicks on a special icon in the title bar.
=item GDK_DESTROY; the window has been destroyed.
=item GDK_EXPOSE; all or part of the window has become visible and needs to be redrawn.
=item GDK_MOTION_NOTIFY; the pointer (usually a mouse) has moved.
=item GDK_BUTTON_PRESS; a mouse button has been pressed.
=item GDK_2BUTTON_PRESS; a mouse button has been double-clicked (clicked twice within a short period of time). Note that each click also generates a GDK_BUTTON_PRESS event.
=item GDK_DOUBLE_BUTTON_PRESS; alias for GDK_2BUTTON_PRESS, added in 3.6.
=item GDK_3BUTTON_PRESS; a mouse button has been clicked 3 times in a short period of time. Note that each click also generates a GDK_BUTTON_PRESS event.
=item GDK_TRIPLE_BUTTON_PRESS; alias for GDK_3BUTTON_PRESS, added in 3.6.
=item GDK_BUTTON_RELEASE; a mouse button has been released.
=item GDK_KEY_PRESS; a key has been pressed.
=item GDK_KEY_RELEASE; a key has been released.
=item GDK_ENTER_NOTIFY; the pointer has entered the window.
=item GDK_LEAVE_NOTIFY; the pointer has left the window.
=item GDK_FOCUS_CHANGE; the keyboard focus has entered or left the window.
=item GDK_CONFIGURE; the size, position or stacking order of the window has changed. Note that GTK+ discards these events for GDK_WINDOW_CHILD windows.
=item GDK_MAP; the window has been mapped.
=item GDK_UNMAP; the window has been unmapped.
=item GDK_PROPERTY_NOTIFY; a property on the window has been changed or deleted.
=item GDK_SELECTION_CLEAR; the application has lost ownership of a selection.
=item GDK_SELECTION_REQUEST; another application has requested a selection.
=item GDK_SELECTION_NOTIFY; a selection has been received.
=item GDK_PROXIMITY_IN; an input device has moved into contact with a sensing surface (e.g. a touchscreen or graphics tablet).
=item GDK_PROXIMITY_OUT; an input device has moved out of contact with a sensing surface.
=item GDK_DRAG_ENTER; the mouse has entered the window while a drag is in progress.
=item GDK_DRAG_LEAVE; the mouse has left the window while a drag is in progress.
=item GDK_DRAG_MOTION; the mouse has moved in the window while a drag is in progress.
=item GDK_DRAG_STATUS; the status of the drag operation initiated by the window has changed.
=item GDK_DROP_START; a drop operation onto the window has started.
=item GDK_DROP_FINISHED; the drop operation initiated by the window has completed.
=item GDK_CLIENT_EVENT; a message has been received from another application.
=item GDK_VISIBILITY_NOTIFY; the window visibility status has changed.
=item GDK_SCROLL; the scroll wheel was turned.
=item GDK_WINDOW_STATE; the state of a window has changed. See GdkWindowState for the possible window states.
=item GDK_SETTING. a setting has been modified.
=item GDK_OWNER_CHANGE; the owner of a selection has changed. This event type was added in 2.6
=item GDK_GRAB_BROKEN; a pointer or keyboard grab was broken. This event type was added in 2.8.
=item GDK_DAMAGE; the content of the window has been changed. This event type was added in 2.14.
=item GDK_TOUCH_BEGIN; A new touch event sequence has just started. This event type was added in 3.4.
=item GDK_TOUCH_UPDATE; A touch event sequence has been updated. This event type was added in 3.4.
=item GDK_TOUCH_END; A touch event sequence has finished. This event type was added in 3.4.
=item GDK_TOUCH_CANCEL; A touch event sequence has been canceled. This event type was added in 3.4.
=item GDK_TOUCHPAD_SWIPE; A touchpad swipe gesture event, the current state is determined by its phase field. This event type was added in 3.18.
=item GDK_TOUCHPAD_PINCH; A touchpad pinch gesture event, the current state is determined by its phase field. This event type was added in 3.18.
=item GDK_PAD_BUTTON_PRESS; A tablet pad button press event. This event type was added in 3.22.
=item GDK_PAD_BUTTON_RELEASE; A tablet pad button release event. This event type was added in 3.22.
=item GDK_PAD_RING; A tablet pad axis event from a "ring". This event type was added in 3.22.
=item GDK_PAD_STRIP; A tablet pad axis event from a "strip". This event type was added in 3.22.
=item GDK_PAD_GROUP_MODE; A tablet pad group mode change. This event type was added in 3.22.
=item GDK_EVENT_LAST; Marks the end of the GdkEventType enumeration. Added in 2.18
=end pod
#TODO look in include file if GDK_2BUTTON_PRESS has same int as GDK_DOUBLE_BUTTON_PRESS
enum GdkEventType is export <
  GDK_NOTHING GDK_DELETE GDK_DESTROY GDK_EXPOSE GDK_MOTION_NOTIFY
  GDK_BUTTON_PRESS GDK_2BUTTON_PRESS GDK_DOUBLE_BUTTON_PRESS
  GDK_3BUTTON_PRESS GDK_TRIPLE_BUTTON_PRESS GDK_BUTTON_RELEASE
  GDK_KEY_PRESS GDK_KEY_RELEASE GDK_ENTER_NOTIFY GDK_LEAVE_NOTIFY
  GDK_FOCUS_CHANGE GDK_CONFIGURE GDK_MAP GDK_UNMAP GDK_PROPERTY_NOTIFY
  GDK_SELECTION_CLEAR GDK_SELECTION_REQUEST GDK_SELECTION_NOTIFY
  GDK_PROXIMITY_IN GDK_PROXIMITY_OUT GDK_DRAG_ENTER GDK_DRAG_LEAVE
  GDK_DRAG_MOTION GDK_DRAG_STATUS GDK_DROP_START GDK_DROP_FINISHED
  GDK_CLIENT_EVENT GDK_VISIBILITY_NOTIFY GDK_SCROLL GDK_WINDOW_STATE
  GDK_SETTING GDK_OWNER_CHANGE GDK_GRAB_BROKEN GDK_DAMAGE GDK_TOUCH_BEGIN
  GDK_TOUCH_UPDATE GDK_TOUCH_END GDK_TOUCH_CANCEL GDK_TOUCHPAD_SWIPE
  GDK_TOUCHPAD_PINCH GDK_PAD_BUTTON_PRESS GDK_PAD_BUTTON_RELEASE
  GDK_PAD_RING GDK_PAD_STRIP GDK_PAD_GROUP_MODE GDK_EVENT_LAST
>;

# ==============================================================================
=begin pod
=head2 class GdkEventAny

Contains the fields which are common to all event classes. This comes in handy to check its type for instance.

=item GdkEventType $.type; the type of the event.
=item GTK::V3::Gdk::GdkWindow $.window; the window which received the event.
=item Int $.send_event; TRUE if the event was sent explicitly.

=end pod
class GdkEventAny is repr('CStruct') is export {
  has GdkEventType $.type;
  has GTK::V3::Gdk::GdkWindow $.window;
  has int8 $.send-event;
}

# ==============================================================================
=begin pod
=head2 class GdkEventKey

Describes a key press or key release event. The type of the event will be one of GDK_KEY_PRESS or GDK_KEY_RELEASE.

=item GdkEventType $.type
=item GTK::V3::Gdk::GdkWindow $.window
=item Int $.send_event
=item UInt $.time; the time of the event in milliseconds.
=item UInt $.state; a bit-mask representing the state of the modifier keys (e.g. Control, Shift and Alt) and the pointer buttons. See GdkModifierType.	[type GdkModifierType].
=item UInt $.keyval; the key that was pressed or released. See the gdk/gdkkeysyms.h header file for a complete list of GDK key codes.
=item Int $.length; the length of string.
=item Str $.string;  deprecated.
=item UInt $.hardware_keycode; the raw code of the key that was pressed or released.
=item UInt $.group; the keyboard group.
=item UInt $.is_modifier; a flag that indicates if hardware_keycode is mapped to a modifier. Since 2.10
=end pod
class GdkEventKey is repr('CStruct') is export {
  has GdkEventType $.event-type;
  has GTK::V3::Gdk::GdkWindow $.window;
  has int8 $.send-event;
  has uint32 $.time;
  has uint $.state;
  has uint $.keyval;
  has int $.length;
  has Str $.string;
  has uint16 $.hardware_keycode;
  has uint8 $.group;
  has uint $.is_modifier;
}

# ==============================================================================
=begin pod
=head2 class GdkEventButton

Used for mouse button press and button release events. The type will be one of GDK_BUTTON_PRESS, GDK_2BUTTON_PRESS, GDK_3BUTTON_PRESS or GDK_BUTTON_RELEASE,

Double and triple-clicks result in a sequence of events being received. For double-clicks the order of events will be: GDK_BUTTON_PRESS, GDK_BUTTON_RELEASE, GDK_BUTTON_PRESS, GDK_2BUTTON_PRESS and GDK_BUTTON_RELEASE.

Note that the first click is received just like a normal button press, while the second click results in a GDK_2BUTTON_PRESS being received just after the GDK_BUTTON_PRESS.

Triple-clicks are very similar to double-clicks, except that GDK_3BUTTON_PRESS is inserted after the third click. The order of the events is: GDK_BUTTON_PRESS, GDK_BUTTON_RELEASE, GDK_BUTTON_PRESS, GDK_2BUTTON_PRESS, GDK_BUTTON_RELEASE, GDK_BUTTON_PRESS, GDK_3BUTTON_PRESS and  GDK_BUTTON_RELEASE.

For a double click to occur, the second button press must occur within 1/4 of a second of the first. For a triple click to occur, the third button press must also occur within 1/2 second of the first button press.

To handle e.g. a triple mouse button presses, all events can be ignored except GDK_3BUTTON_PRESS

  method handle-keypress ( :$widget, GdkEventButton :$event ) {
    # check if left mouse button was pressed three times
    if $event.type ~~ GDK_3BUTTON_PRESS and $event.button == 1 {
      ...
    }
  }

=item GdkEventType $.type;
=item GTK::V3::Gdk::GdkWindow $.window;
=item Int $.send_event;
=item UInt $.time; the time of the event in milliseconds.
=item Num $.x; the x coordinate of the pointer relative to the window.
=item Num $.y; the y coordinate of the pointer relative to the window.
=item Pointer[Num] $.axes; x , y translated to the axes of device , or NULL if device is the mouse.
=item UInt $.state; a bit-mask representing the state of the modifier keys (e.g. Control, Shift and Alt) and the pointer buttons. See GdkModifierType. [type GdkModifierType]
=item UInt $.button; the button which was pressed or released, numbered from 1 to 5. Normally button 1 is the left mouse button, 2 is the middle button, and 3 is the right button. On 2-button mice, the middle button can often be simulated by pressing both mouse buttons together.
=item GTK::V3::Gdk::GdkDevice $.device; the master device that the event originated from. Use gdk_event_get_source_device() to get the slave device.
=item Num $.x_root; the x coordinate of the pointer relative to the root of the screen.
=item Num $.y_root; the y coordinate of the pointer relative to the root of the screen.

=end pod
class GdkEventButton is repr('CStruct') is export {
  has GdkEventType $.event-type;
  has GTK::V3::Gdk::GdkWindow $.window;
  has int8 $.send-event;
  has uint32 $.time;
  has num64 $.x;
  has num64 $.y;
  has Pointer[num64] $.axes;
  has uint $.state;
  has uint $.button;
  has GTK::V3::Gdk::GdkDevice  $.device;
  has num64 $.x_root;
  has num64 $.y_root;
}

# ==============================================================================
=begin pod
=head2 GdkEvent

The event structures contain data specific to each type of event in GDK. The type is a union of all structures explained above.
=end pod
class GdkEvent is repr('CUnion') is export {
  has GdkEventAny $.event-any;
  has GdkEventKey $.event-key;
  has GdkEventButton $.event-button;
}

# ==============================================================================
# No need to define subs because all can be read from structures above.
#`{{

=begin pod
=head1 Methods

=head2 [gdk_event_] get_button

  method gdk_event_get_button ( uint $button is rw --> Int )

Extract the button number from an event.
=end pod
sub gdk_event_get_button ( GdkEvent $event, uint $button is rw )
  returns int32
  is native(&gobject-lib)
  { * }
}}
