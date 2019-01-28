use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
#use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gdk on Fedora-28
unit module GTK::Glade::Native::Gdk:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------

enum GdkModifierType is export (
  GDK_SHIFT_MASK    => 1 +< 0,
  GDK_LOCK_MASK     => 1 +< 1,
  GDK_CONTROL_MASK  => 1 +< 2,
  GDK_MOD1_MASK     => 1 +< 3,
  GDK_MOD2_MASK     => 1 +< 4,
  GDK_MOD3_MASK     => 1 +< 5,
  GDK_MOD4_MASK     => 1 +< 6,
  GDK_MOD5_MASK     => 1 +< 7,
  GDK_BUTTON1_MASK  => 1 +< 8,
  GDK_BUTTON2_MASK  => 1 +< 9,
  GDK_BUTTON3_MASK  => 1 +< 10,
  GDK_BUTTON4_MASK  => 1 +< 11,
  GDK_BUTTON5_MASK  => 1 +< 12,

  GDK_MODIFIER_RESERVED_13_MASK  => 1 +< 13,
  GDK_MODIFIER_RESERVED_14_MASK  => 1 +< 14,
  GDK_MODIFIER_RESERVED_15_MASK  => 1 +< 15,
  GDK_MODIFIER_RESERVED_16_MASK  => 1 +< 16,
  GDK_MODIFIER_RESERVED_17_MASK  => 1 +< 17,
  GDK_MODIFIER_RESERVED_18_MASK  => 1 +< 18,
  GDK_MODIFIER_RESERVED_19_MASK  => 1 +< 19,
  GDK_MODIFIER_RESERVED_20_MASK  => 1 +< 20,
  GDK_MODIFIER_RESERVED_21_MASK  => 1 +< 21,
  GDK_MODIFIER_RESERVED_22_MASK   => 1 +< 22,
  GDK_MODIFIER_RESERVED_23_MASK   => 1 +< 23,
  GDK_MODIFIER_RESERVED_24_MASK   => 1 +< 24,
  GDK_MODIFIER_RESERVED_25_MASK   => 1 +< 25,

  #`{{
   The next few modifiers are used by XKB, so we skip to the end.
   Bits 15 - 25 are currently unused. Bit 29 is used internally.
  }}

  GDK_SUPER_MASK                  => 1 +< 26,
  GDK_HYPER_MASK                  => 1 +< 27,
  GDK_META_MASK                   => 1 +< 28,

  GDK_MODIFIER_RESERVED_29_MASK   => 1 +< 29,

  GDK_RELEASE_MASK                => 1 +< 30,

  #`{{
   Combination of GDK_SHIFT_MASK..GDK_BUTTON5_MASK + GDK_SUPER_MASK
     + GDK_HYPER_MASK + GDK_META_MASK + GDK_RELEASE_MASK */
  }}
  GDK_MODIFIER_MASK               => 0x5c001fff
);

#`{{
enum GdkEventType is export (
  GDK_NOTHING		=> -1,
  GDK_DELETE		=> 0,
  GDK_DESTROY		=> 1,
  GDK_EXPOSE		=> 2,
  GDK_MOTION_NOTIFY	=> 3,
  GDK_BUTTON_PRESS	=> 4,
  GDK_2BUTTON_PRESS	=> 5,
  GDK_DOUBLE_BUTTON_PRESS => GDK_2BUTTON_PRESS,
  GDK_3BUTTON_PRESS	=> 6,
  GDK_TRIPLE_BUTTON_PRESS => GDK_3BUTTON_PRESS,
  GDK_BUTTON_RELEASE	=> 7,
  GDK_KEY_PRESS		=> 8,
  GDK_KEY_RELEASE	=> 9,
  GDK_ENTER_NOTIFY	=> 10,
  GDK_LEAVE_NOTIFY	=> 11,
  GDK_FOCUS_CHANGE	=> 12,
  GDK_CONFIGURE		=> 13,
  GDK_MAP		=> 14,
  GDK_UNMAP		=> 15,
  GDK_PROPERTY_NOTIFY	=> 16,
  GDK_SELECTION_CLEAR	=> 17,
  GDK_SELECTION_REQUEST => 18,
  GDK_SELECTION_NOTIFY	=> 19,
  GDK_PROXIMITY_IN	=> 20,
  GDK_PROXIMITY_OUT	=> 21,
  GDK_DRAG_ENTER        => 22,
  GDK_DRAG_LEAVE        => 23,
  GDK_DRAG_MOTION       => 24,
  GDK_DRAG_STATUS       => 25,
  GDK_DROP_START        => 26,
  GDK_DROP_FINISHED     => 27,
  GDK_CLIENT_EVENT	=> 28,
  GDK_VISIBILITY_NOTIFY => 29,
  GDK_SCROLL            => 31,
  GDK_WINDOW_STATE      => 32,
  GDK_SETTING           => 33,
  GDK_OWNER_CHANGE      => 34,
  GDK_GRAB_BROKEN       => 35,
  GDK_DAMAGE            => 36,
  GDK_TOUCH_BEGIN       => 37,
  GDK_TOUCH_UPDATE      => 38,
  GDK_TOUCH_END         => 39,
  GDK_TOUCH_CANCEL      => 40,
  GDK_TOUCHPAD_SWIPE    => 41,
  GDK_TOUCHPAD_PINCH    => 42,
  GDK_PAD_BUTTON_PRESS  => 43,
  GDK_PAD_BUTTON_RELEASE => 44,
  GDK_PAD_RING          => 45,
  GDK_PAD_STRIP         => 46,
  GDK_PAD_GROUP_MODE    => 47,
  GDK_EVENT_LAST        # helper variable for decls */
} GdkEventType;
}}

#--[ Gdk screen ]---------------------------------------------------------------
class GdkScreen is repr('CPointer') is export { }

sub gdk_screen_get_default ( )
    returns GdkScreen
    is native(&gdk-lib)
    is export
    { * }

#--[ gdk display ]--------------------------------------------------------------
class GdkDisplay is repr('CPointer') is export { }

sub gdk_display_warp_pointer (
    GdkDisplay $display, GdkScreen $screen, int32 $x, int32 $y
  ) is native(&gdk-lib)
    is export
    { * }

#--[ gdk window ]---------------------------------------------------------------
class GdkWindow is repr('CPointer') is export { }

sub gdk_window_get_origin (
    GdkWindow $window, int32 $x is rw, int32 $y is rw
    ) returns int32
      is native(&gdk-lib)
      is export
      { * }
