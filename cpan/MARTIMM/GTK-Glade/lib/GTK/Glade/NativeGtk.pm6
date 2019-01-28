# This file is copied from the Gtk::Simple package. The reason to copy the file
# is to remove dependency on that package because only 2 files can be used

# CHANGES:
# 2019-01-11 There are functions added

use v6;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Glib::GObject;
#use GTK::Glade::Native::Gtk;
#use GTK::Glade::Native::Gdk;
use GTK::Glade::Native::Gtk::Widget;
use NativeCall;

unit module GTK::Glade::NativeGtk;

#--[ Constants and enum ]-------------------------------------------------------
#`{{
enum GtkWindowPosition is export (
    GTK_WIN_POS_NONE               => 0,
    GTK_WIN_POS_CENTER             => 1,
    GTK_WIN_POS_MOUSE              => 2,
    GTK_WIN_POS_CENTER_ALWAYS      => 3,
    GTK_WIN_POS_CENTER_ON_PARENT   => 4,
);
}}

enum GtkFileChooserAction is export (
    GTK_FILE_CHOOSER_ACTION_OPEN           => 0,
    GTK_FILE_CHOOSER_ACTION_SAVE           => 1,
    GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER  => 2,
    GTK_FILE_CHOOSER_ACTION_CREATE_FOLDER  => 3,
);

enum GtkPlacesOpenFlags is export (
    GTK_PLACES_OPEN_NORMAL     => 0,
    GTK_PLACES_OPEN_NEW_TAB    => 1,
    GTK_PLACES_OPEN_NEW_WINDOW => 2,
);

#`{{
enum GtkLevelBarMode is export (
    GTK_LEVEL_BAR_MODE_CONTINUOUS => 0,
    GTK_LEVEL_BAR_MODE_DISCRETE   => 1,
);
}}
# Determines how the size should be computed to achieve the one of the
# visibility mode for the scrollbars.
enum GtkPolicyType is export (
    GTK_POLICY_ALWAYS => 0,     #The scrollbar is always visible.
                                #The view size is independent of the content.
    GTK_POLICY_AUTOMATIC => 1,  #The scrollbar will appear and disappear as necessary.
                                #For example, when all of a Gtk::TreeView can not be seen.
    GTK_POLICY_NEVER => 2,      #The scrollbar should never appear.
                                #In this mode the content determines the size.
    GTK_POLICY_EXTERNAL => 3,   #Don't show a scrollbar, but don't force the size to follow the content.
                                #This can be used e.g. to make multiple scrolled windows share a scrollbar.
);

# /usr/include/glib-2.0/gobject/gsignal.h
constant G_CONNECT_AFTER is export = 1;
constant G_CONNECT_SWAPPED is export = 2;

# /usr/include/glib-2.0/glib/gmain.h
constant G_PRIORITY_HIGH is export = -100;
constant G_PRIORITY_DEFAULT is export = 0;
constant G_PRIORITY_HIGH_IDLE is export = 100;
constant G_PRIORITY_DEFAULT_IDLE is export = 200;
constant G_PRIORITY_LOW is export = 300;

#`{{
# /usr/include/glib-2.0/gtk/gtkstyleprovider.h
# https://developer.gnome.org/gtk3/stable/GtkStyleProvider.html#GTK-STYLE-PROVIDER-PRIORITY-FALLBACK:CAPS
enum GtkStyleProviderPriority is export (
    GTK_STYLE_PROVIDER_PRIORITY_FALLBACK => 1,
    GTK_STYLE_PROVIDER_PRIORITY_THEME => 200,
    GTK_STYLE_PROVIDER_PRIORITY_SETTINGS => 400,
    GTK_STYLE_PROVIDER_PRIORITY_APPLICATION => 600,
    GTK_STYLE_PROVIDER_PRIORITY_USER => 800,
);
}}
#`[[
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
]]
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

#`{{
# gtk/gtkenums.h
enum GtkOrientation is export (
  GTK_ORIENTATION_HORIZONTAL    => 0,
  GTK_ORIENTATION_VERTICAL      => 1,
);
}}
#`{{ -> toplevel
enum GtkResponseType is export (
  GTK_RESPONSE_NONE         => -1,
  GTK_RESPONSE_REJECT       => -2,
  GTK_RESPONSE_ACCEPT       => -3,
  GTK_RESPONSE_DELETE_EVENT => -4,
  GTK_RESPONSE_OK           => -5,
  GTK_RESPONSE_CANCEL       => -6,
  GTK_RESPONSE_CLOSE        => -7,
  GTK_RESPONSE_YES          => -8,
  GTK_RESPONSE_NO           => -9,
  GTK_RESPONSE_APPLY        => -10,
  GTK_RESPONSE_HELP         => -11,
);
}}

#--[ display ]------------------------------------------------------------------
#`{{
sub gdk_display_warp_pointer (
  GdkDisplay $display, GdkScreen $screen, int32 $x, int32 $y
  ) is native(&gdk-lib)
    is export
    { * }
}}
#`{{
#--[ Gdk screen ]---------------------------------------------------------------
sub gdk_screen_get_default ( )
    returns GdkScreen
    is native(&gdk-lib)
    is export
    { * }
}}
#`{{
#--[ gtk_window_ ]--------------------------------------------------------------
sub gtk_window_new(int32 $window_type)
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

sub gtk_window_set_title(GtkWidget $w, Str $title)
    is native(&gtk-lib)
    is export
    returns GtkWidget
    { * }

sub gtk_window_set_position(GtkWidget $window, int32 $position)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_window_set_default_size(GtkWidget $window, int32 $width, int32 $height)
    is native(&gtk-lib)
    is export
    { * }

# void gtk_window_set_modal (GtkWindow *window, gboolean modal);
# can be set in glade
sub gtk_window_set_modal ( GtkWidget $window, Bool $modal)
    is native(&gtk-lib)
    is export
    { * }

# void gtk_window_set_transient_for ( GtkWindow *window, GtkWindow *parent);
sub gtk_window_set_transient_for( GtkWindow $window, GtkWindow $parent)
    is native(&gtk-lib)
    is export
    { * }

sub gdk_window_get_origin (
    GdkWindow $window, int32 $x is rw, int32 $y is rw
    ) returns int32
      is native(&gdk-lib)
      is export
      { * }

sub gtk_widget_get_has_window ( GtkWidget $window )
    returns Bool
    is native(&gtk-lib)
    is export
    { * }
}}
#`{{
#--[ gtk_widget_ ]--------------------------------------------------------------
sub gtk_widget_get_display ( GtkWidget $widget )
    returns GdkDisplay
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_show(GtkWidget $widgetw)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_hide(GtkWidget $widgetw)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_show_all(GtkWidget $widgetw)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_no_show_all(GtkWidget $widgetw, int32 $no_show_all)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_no_show_all(GtkWidget $widgetw)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_destroy(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_sensitive(GtkWidget $widget, int32 $sensitive)
    is native(&gtk-lib)
    is export

    { * }
sub gtk_widget_get_sensitive(GtkWidget $widget)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_size_request(GtkWidget $widget, int32 $w, int32 $h)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_allocated_height(GtkWidget $widget)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_allocated_width(GtkWidget $widget)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_queue_draw(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_tooltip_text(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    returns Str
    { * }

sub gtk_widget_set_tooltip_text(GtkWidget $widget, Str $text)
    is native(&gtk-lib)
    is export
    { * }

# void gtk_widget_set_name ( GtkWidget *widget, const gchar *name );
sub gtk_widget_set_name ( GtkWidget $widget, Str $name )
    is native(&gtk-lib)
    is export
    { * }

# const gchar *gtk_widget_get_name ( GtkWidget *widget );
sub gtk_widget_get_name ( GtkWidget $widget )
    returns Str
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_get_window ( GtkWidget $widget )
    returns GdkWindow
    is native(&gtk-lib)
    is export
    { * }

sub gtk_widget_set_visible ( GtkWidget $widget, Bool $visible)
    is native(&gtk-lib)
    is export
    { * }
}}
#`{{
#--[ gtk_container_ ]-----------------------------------------------------------
sub gtk_container_add(GtkWidget $container, GtkWidget $widgen)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_container_get_border_width(GtkWidget $container)
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_container_set_border_width(GtkWidget $container, int32 $border_width)
    is native(&gtk-lib)
    is export
    { * }
}}
#`{{
#--[ signals and events ]-------------------------------------------------------
# gulong g_signal_connect_object ( gpointer instance,
#        const gchar *detailed_signal, GCallback c_handler,
#        gpointer gobject, GConnectFlags connect_flags);
sub g_signal_connect_object( GtkWidget $widget, Str $signal,
    &Handler ( GtkWidget $h_widget, OpaquePointer $h_data),
    OpaquePointer $data, int32 $connect_flags)
      returns uint32
      is native(&gobject-lib)
#      is symbol('g_signal_connect_object')
      is export
      { * }

sub g_signal_handler_disconnect( GtkWidget $widget, int32 $handler_id)
    is native(&gobject-lib)
    is export
    { * }

# from /usr/include/glib-2.0/gobject/gsignal.h
# #define g_signal_connect( instance, detailed_signal, c_handler, data)
# as g_signal_connect_data (
#      (instance), (detailed_signal),
#      (c_handler), (data), NULL, (GConnectFlags) 0
#    )
# So;
# gulong g_signal_connect_data ( gpointer instance,
#          const gchar *detailed_signal, GCallback c_handler,
#          gpointer data,  GClosureNotify destroy_data,
#          GConnectFlags connect_flags );
sub g_signal_connect_data( GtkWidget $widget, Str $signal,
    &Handler ( GtkWidget $h_widget, OpaquePointer $h_data),
    OpaquePointer $data, OpaquePointer $destroy_data, int32 $connect_flags
    ) returns int32
      is native(&gobject-lib)
      { * }

# a GQuark is a guint32, $detail is a quark
# See https://developer.gnome.org/glib/stable/glib-Quarks.html
sub g_signal_emit (
    OpaquePointer $instance, uint32 $signal_id, uint32 $detail,
    GtkWidget $widget, Str $data, Str $return-value is rw
    ) is native(&gobject-lib)
      is export
      { * }

sub g_signal_emit_by_name (
    OpaquePointer $instance, Str $detailed_signal,
    GtkWidget $widget, Str $data, Str $return-value is rw
    ) is native(&gobject-lib)
      is export
      { * }
}}

#`{{
# /usr/include/gtk-3.0/gtk/gtkmain.h
sub gtk_events_pending ( )
    returns Bool
    is native(&gtk-lib)
    is export
    { * }
}}
#`{{
#--[ Quarks ]-------------------------------------------------------------------
sub g_quark_from_string ( Str $string )
    returns uint32
    is native(&glib-lib)
    is export
    { * }

sub g_quark_to_string ( uint32 $quark )
    returns Str
    is native(&glib-lib)
    is export
    { * }
}}
#`{{
#-------------------------------------------------------------------------------
sub g_idle_add( &Handler (OpaquePointer $h_data), OpaquePointer $data)
    returns int32
    is native(&glib-lib)
    is export
    { * }

sub g_timeout_add(
    int32 $interval, &Handler (OpaquePointer $h_data, --> int32),
    OpaquePointer $data
    )  returns int32
      is native(&gtk-lib)
      is export
      { * }
}}
#`{{
#--[ App ]----------------------------------------------------------------------
sub gtk_init ( CArray[int32] $argc, CArray[CArray[Str]] $argv )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_main ( )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_main_quit ( )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_main_iteration ( )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_main_iteration_do ( Bool $blocking )
    returns Bool
    is native(&gtk-lib)
    is export
    { * }

sub gtk_main_level ( )
    returns uint32
    is native(&gtk-lib)
    is export
    { * }
}}
#`{{
#--[ Box ]----------------------------------------------------------------------
# GtkOrientation is an unsigned int (enum)
sub gtk_box_new ( uint32 $orientation, int32 $spacing )
    returns GtkWidget
    is native(&gtk-lib)
    is export(:box)
    { * }

sub gtk_box_pack_start ( GtkWidget, GtkWidget, Bool, Bool, uint32 )
    is native(&gtk-lib)
    is export(:box)
    { * }

sub gtk_box_get_spacing ( GtkWidget $box )
    returns int32
    is native(&gtk-lib)
    is export(:box)
    { * }

sub gtk_box_set_spacing ( GtkWidget $box, int32 $spacing )
    is native(&gtk-lib)
    is export(:box)
    { * }

#
# HBox
#
sub gtk_hbox_new(int32, int32)
    is native(&gtk-lib)
    is export(:hbox)
    returns GtkWidget
    { * }

#
# VBox
#
sub gtk_vbox_new(int32, int32)
    is native(&gtk-lib)
    is export(:vbox)
    returns GtkWidget
    { * }
}}

#`{{
#--[ Listbox ]------------------------------------------------------------------
sub gtk_list_box_insert ( GtkWidget $box, GtkWidget $child, int32 $position)
    is native(&gtk-lib)
    is export
    { * }
}}
#
# Button
#
#`{{
sub gtk_button_new_with_label(Str $label)
    is native(&gtk-lib)
    is export(:button)
    returns GtkWidget
    { * }

sub gtk_button_get_label(GtkWidget $widget)
    is native(&gtk-lib)
    is export(:button)
    returns Str
    { * }

sub gtk_button_set_label(GtkWidget $widget, Str $label)
    is native(&gtk-lib)
    is export(:button)
    { * }
}}
#
# CheckButton
#
#`{{
sub gtk_check_button_new_with_label(Str $label)
    is native(&gtk-lib)
    is export(:check-button)
    returns GtkWidget
    { * }
}}
#
# ToggleButton
#
#`{{
sub gtk_toggle_button_new_with_label(Str $label)
    is native(&gtk-lib)
    is export(:toggle-button)
    returns GtkWidget
    { * }

sub gtk_toggle_button_get_active(GtkWidget $w)
    is native(&gtk-lib)
    is export(:toggle-button)
    returns int32
    { * }

sub gtk_toggle_button_set_active(GtkWidget $w, int32 $active)
    is native(&gtk-lib)
    is export(:toggle-button)
    returns int32
    { * }
}}
#`{{
# ComboBoxText
#
sub gtk_combo_box_text_new()
    is native(&gtk-lib)
    is export(:combo-box-text)
    returns GtkWidget
    { * }

sub gtk_combo_box_text_new_with_entry()
    is native(&gtk-lib)
    is export(:combo-box-text)
    returns GtkWidget
    { * }

sub gtk_combo_box_text_prepend_text(GtkWidget $widget, Str $text)
    is native(&gtk-lib)
    is export(:combo-box-text)
    { * }

sub gtk_combo_box_text_append_text(GtkWidget $widget, Str $text)
    is native(&gtk-lib)
    is export(:combo-box-text)
    { * }

sub gtk_combo_box_text_insert_text(GtkWidget $widget, int32 $position, Str $text)
    is native(&gtk-lib)
    is export(:combo-box-text)
    { * }

sub gtk_combo_box_set_active(GtkWidget $widget, int32 $index)
    is native(&gtk-lib)
    is export(:combo-box-text)
    { * }

sub gtk_combo_box_get_active(GtkWidget $widget)
    is native(&gtk-lib)
    is export(:combo-box-text)
    returns int32
    { * }

sub gtk_combo_box_text_get_active_text(GtkWidget $widget)
    is native(&gtk-lib)
    is export(:combo-box-text)
    returns Str
    { * }

sub gtk_combo_box_text_remove(GtkWidget $widget, int32 $position)
    is native(&gtk-lib)
    is export(:combo-box-text)
    { * }

sub gtk_combo_box_text_remove_all(GtkWidget $widget)
    is native(&gtk-lib)
    is export(:combo-box-text)
    { * }
}}

#`{{
#--[ Grid ]---------------------------------------------------------------------
sub gtk_grid_new()
    returns GtkWidget
    is native(&gtk-lib)
    is export(:grid)
    { * }

sub gtk_grid_attach( GtkWidget $grid, GtkWidget $child, int32 $x, int32 $y,
    int32 $w, int32 $h
    ) is native(&gtk-lib)
      is export(:grid)
      { * }

sub gtk_grid_insert_row ( GtkWidget $grid, int32 $position)
    is native(&gtk-lib)
    is export(:grid)
    { * }

sub gtk_grid_insert_column ( GtkWidget $grid, int32 $position)
    is native(&gtk-lib)
    is export(:grid)
    { * }
}}
#`{{
# Scale
#
sub gtk_scale_new_with_range( int32 $orientation, num64 $min, num64 $max, num64 $step )
    is native(&gtk-lib)
    is export(:scale)
    returns GtkWidget
    { * }

# orientation:
# horizontal = 0
# vertical = 1 , inverts so that big numbers at top.
sub gtk_scale_set_digits( GtkWidget $scale, int32 $digits )
    is native( &gtk-lib)
    is export(:scale)
    { * }

sub gtk_range_get_value( GtkWidget $scale )
    is native(&gtk-lib)
    is export(:scale)
    returns num64
    { * }

sub gtk_range_set_value( GtkWidget $scale, num64 $value )
    is native(&gtk-lib)
    is export(:scale)
    { * }

sub gtk_range_set_inverted( GtkWidget $scale, Bool $invertOK )
    is native(&gtk-lib)
    is export(:scale)
    { * }
}}
#`{{
# Separator
#
sub gtk_separator_new(int32 $orientation)
    is native(&gtk-lib)
    is export(:separator)
    returns GtkWidget
    { * }
}}

#`{{
# ActionBar
#
sub gtk_action_bar_new()
    is native(&gtk-lib)
    is export(:action-bar)
    returns GtkWidget
    { * }

sub gtk_action_bar_pack_start(GtkWidget $widget, GtkWidget $child)
    is native(&gtk-lib)
    is export(:action-bar)
    { * }

sub gtk_action_bar_pack_end(GtkWidget $widget, GtkWidget $child)
    is native(&gtk-lib)
    is export(:action-bar)
    { * }

sub gtk_action_bar_get_center_widget(GtkWidget $widget)
    is native(&gtk-lib)
    is export(:action-bar)
    returns GtkWidget
    { * }

sub gtk_action_bar_set_center_widget(GtkWidget $widget, GtkWidget $centre-widget)
    is native(&gtk-lib)
    is export(:action-bar)
    { * }
}}
#`{{
#--[ Entry ]--------------------------------------------------------------------
sub gtk_entry_new()
    is native(&gtk-lib)
    is export(:entry)
    returns GtkWidget
    { * }

sub gtk_entry_get_text(GtkWidget $entry)
    is native(&gtk-lib)
    is export(:entry)
    returns Str
    { * }

sub gtk_entry_set_text(GtkWidget $entry, Str $text)
    is native(&gtk-lib)
    is export(:entry)
    { * }

sub gtk_entry_set_visibility ( GtkWidget $entry, Bool $visible)
    is native(&gtk-lib)
    is export(:entry)
    { * }
}}
#`{{
# Frame
#
sub gtk_frame_new(Str $label)
    is native(&gtk-lib)
    is export(:frame)
    returns GtkWidget
    { * }

sub gtk_frame_get_label(GtkWidget $widget)
    is native(&gtk-lib)
    is export(:frame)
    returns Str
    { * }

sub gtk_frame_set_label(GtkWidget $widget, Str $label)
    is native(&gtk-lib)
    is export(:frame)
    { * }

#
# Label
#
sub gtk_label_new(Str $text)
    is native(&gtk-lib)
    is export(:label)
    returns GtkWidget
    { * }

sub gtk_label_get_text(GtkWidget $label)
    is native(&gtk-lib)
    is export(:label)
    returns Str
    { * }

sub gtk_label_set_text(GtkWidget $label, Str $text)
    is native(&gtk-lib)
    is export(:label)
    { * }

sub gtk_label_set_markup(GtkWidget $label, Str $text)
    is native(&gtk-lib)
    is export(:label)
    { * }
}}

#
# DrawingArea
#
sub gtk_drawing_area_new()
    is native(&gtk-lib)
    is export(:drawing-area)
    returns GtkWidget
    { * }

#
# ProgressBar
#
sub gtk_progress_bar_new()
    is native(&gtk-lib)
    is export(:progress-bar)
    returns GtkWidget
    { * }

sub gtk_progress_bar_pulse(GtkWidget $widget)
    is native(&gtk-lib)
    is export(:progress-bar)
    { * }

sub gtk_progress_bar_set_fraction(GtkWidget $widget, num64 $fractions)
    is native(&gtk-lib)
    is export(:progress-bar)
    { * }

sub gtk_progress_bar_get_fraction(GtkWidget $widget)
    is native(&gtk-lib)
    is export(:progress-bar)
    returns num64
    { * }

#
# Spinner
#
sub gtk_spinner_new()
    is native(&gtk-lib)
    is export(:spinner)
    returns GtkWidget
    { * }

sub gtk_spinner_start(GtkWidget $widget)
    is native(&gtk-lib)
    is export(:spinner)
    { * }

sub gtk_spinner_stop(GtkWidget $widget)
    is native(&gtk-lib)
    is export(:spinner)
    { * }

#
# StatusBar
#
sub gtk_statusbar_new()
    is native(&gtk-lib)
    is export(:status-bar)
    returns GtkWidget
    { * }

sub gtk_statusbar_get_context_id(GtkWidget $widget, Str $description)
    is native(&gtk-lib)
    is export(:status-bar)
    returns uint32
    { * }

sub gtk_statusbar_push(GtkWidget $widget, uint32 $context_id, Str $text)
    is native(&gtk-lib)
    is export(:status-bar)
    returns uint32
    { * }

sub gtk_statusbar_pop(GtkWidget $widget, uint32 $context-id)
    is native(&gtk-lib)
    is export(:status-bar)
    { * }

sub gtk_statusbar_remove(GtkWidget $widget, uint32 $context-id, uint32 $message-id)
    is native(&gtk-lib)
    is export(:status-bar)
    { * }

sub gtk_statusbar_remove_all(GtkWidget $widget, uint32 $context-id)
    is native(&gtk-lib)
    is export(:status-bar)
    { * }

#
# Switch
#
sub gtk_switch_new()
    is native(&gtk-lib)
    is export(:switch)
    returns GtkWidget
    { * }

sub gtk_switch_get_active(GtkWidget $w)
    is export(:switch)
    is native(&gtk-lib)
    returns int32
    { * }

sub gtk_switch_set_active(GtkWidget $w, int32 $a)
    is native(&gtk-lib)
    is export(:switch)
    { * }

#--[ TextView ]-----------------------------------------------------------------
sub gtk_text_view_new()
    is native(&gtk-lib)
    is export(:text-view)
    returns GtkWidget
    { * }

sub gtk_text_view_get_buffer ( GtkWidget $view )
    is native(&gtk-lib)
    is export(:text-view)
    returns OpaquePointer
    { * }

sub gtk_text_buffer_get_text ( OpaquePointer $buffer, CArray[int32] $start,
        CArray[int32] $end, int32 $show_hidden )
    is native(&gtk-lib)
    is export
    returns Str
    { * }

sub gtk_text_buffer_get_start_iter ( OpaquePointer $buffer, CArray[int32] $i )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_text_buffer_get_end_iter(OpaquePointer $buffer, CArray[int32] $i)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_text_buffer_set_text(OpaquePointer $buffer, Str $text, int32 $len)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_text_view_set_editable(GtkWidget $widget, int32 $setting)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_text_view_get_editable(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    returns int32
    { * }

sub gtk_text_view_set_cursor_visible(GtkWidget $widget, int32 $setting)
    is native(&gtk-lib)
    is export
    { * }

sub gtk_text_view_get_cursor_visible(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    returns int32
    { * }

sub gtk_text_view_get_monospace(GtkWidget $widget)
    is native(&gtk-lib)
    is export
    returns int32
    { * }

sub gtk_text_view_set_monospace(GtkWidget $widget, int32 $setting)
    is native(&gtk-lib)
    is export
    { * }

# void gtk_text_buffer_insert (
#      GtkTextBuffer *buffer, GtkTextIter *iter, const gchar *text, gint len);
sub gtk_text_buffer_insert( OpaquePointer $buffer, CArray[int32] $start,
    Str $text, int32 $len
    ) is native(&gtk-lib)
      is export
      { * }

#
# Toolbar
#
sub gtk_toolbar_new()
    returns GtkWidget
    is native(&gtk-lib)
    is export(:toolbar)
    { * }

sub gtk_tool_button_new_from_stock(Str)
    returns GtkWidget
    is native(&gtk-lib)
    is export(:toolbar)
    { * }

sub gtk_separator_tool_item_new()
    returns GtkWidget
    is native(&gtk-lib)
    is export(:toolbar)
    { * }

sub gtk_toolbar_set_style(Pointer $toolbar, int32 $style)
    is native(&gtk-lib)
    is export(:toolbar)
    { * }

sub gtk_toolbar_insert(Pointer $toolbar, Pointer $button, int32)
    is native(&gtk-lib)
    is export(:toolbar)
    { * }

#`{{
# MenuBar
#
sub gtk_menu_bar_new()
    returns GtkWidget
    is native(&gtk-lib)
    is export(:menu-bar)
    { * }

#
# Menu
#
sub gtk_menu_new()
    returns GtkWidget
    is native(&gtk-lib)
    is export(:menu)
    { * }

sub gtk_menu_shell_append(Pointer $menu, Pointer $menu-item)
    is native(&gtk-lib)
    is export(:menu)
    { * }

#
# MenuItem
#
sub gtk_menu_item_new_with_label(Str $label)
    returns GtkWidget
    is native(&gtk-lib)
    is export(:menu-item)
    { * }

sub gtk_menu_item_set_submenu(Pointer $menu-item, Pointer $sub-menu)
    is native(&gtk-lib)
    is export(:menu-item)
    { * }
}}

#
# FileChooserButton
#
sub gtk_file_chooser_button_new(Str $title, int32 $action)
    returns GtkWidget
    is native(&gtk-lib)
    is export(:file-chooser)
    { * }

sub gtk_file_chooser_button_get_title(GtkWidget $button)
    returns Str
    is native(&gtk-lib)
    is export(:file-chooser)
    { * }

sub gtk_file_chooser_button_set_title(GtkWidget $button, Str $title)
    is native(&gtk-lib)
    is export(:file-chooser)
    { * }

sub gtk_file_chooser_button_get_width_chars(GtkWidget $button)
    returns int32
    is native(&gtk-lib)
    is export(:file-chooser)
    { * }

sub gtk_file_chooser_button_set_width_chars(GtkWidget $button, int32 $n-chars)
    is native(&gtk-lib)
    is export(:file-chooser)
    { * }

sub gtk_file_chooser_get_filename(GtkWidget $file-chooser)
    returns Str
    is native(&gtk-lib)
    is export(:file-chooser)
    { * }

sub gtk_file_chooser_set_filename(GtkWidget $file-chooser, Str $file-name)
    is native(&gtk-lib)
    is export(:file-chooser)
    { * }

#
# PlacesSidebar
#
sub gtk_places_sidebar_new()
    returns GtkWidget
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_get_open_flags(GtkWidget $sidebar)
    returns int32
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_get_local_only(GtkWidget $sidebar)
    returns Bool
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_set_local_only(GtkWidget $sidebar, Bool $local-only)
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_set_open_flags(GtkWidget $sidebar, int32 $flags)
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_get_show_connect_to_server(GtkWidget $siderbar)
    returns int32
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_set_show_connect_to_server(
    GtkWidget $sidebar,
    Bool $show-connect-to-server)
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_get_show_desktop(GtkWidget $sidebar)
    returns Bool
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_set_show_desktop(GtkWidget $sidebar, Bool $show-desktop)
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_get_show_other_locations(GtkWidget $sidebar)
    returns Bool
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_set_show_other_locations(
    GtkWidget $sidebar, Bool $show-other-locations
)   is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_get_show_recent(GtkWidget $sidebar)
    returns Bool
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_set_show_recent(GtkWidget $sidebar, Bool $show-recent)
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_get_show_trash(GtkWidget $sidebar)
    returns Bool
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

sub gtk_places_sidebar_set_show_trash(GtkWidget $sidebar, Bool $show-trash)
    is native(&gtk-lib)
    is export(:places-sidebar)
    { * }

#
# RadioButton
#
sub gtk_radio_button_new_with_label(GtkWidget $group, Str $label)
    returns GtkWidget
    is native(&gtk-lib)
    is export(:radio-button)
    { * }

sub gtk_radio_button_join_group(GtkWidget $radio-button, GtkWidget $group-source)
    is native(&gtk-lib)
    is export(:radio-button)
    { * }


#
# LinkButton
#
sub gtk_link_button_new_with_label( Str $uri, Str $label )
    returns GtkWidget
    is native(&gtk-lib)
    is export(:link-button)
    { * }

sub gtk_link_button_get_uri(GtkWidget $link-button)
    returns Str
    is native(&gtk-lib)
    is export(:link-button)
    { * }

sub gtk_link_button_set_uri(GtkWidget $link-button, Str $uri)
    is native(&gtk-lib)
    is export(:link-button)
    { * }

sub gtk_link_button_get_visited(GtkWidget $link-button)
    returns Bool
    is native(&gtk-lib)
    is export(:link-button)
    { * }

sub gtk_link_button_set_visited(GtkWidget $link-button, Bool $visited)
    is native(&gtk-lib)
    is export(:link-button)
    { * }

#
# LevelBar
#
sub gtk_level_bar_new()
    is native(&gtk-lib)
    is export(:level-bar)
    returns GtkWidget
    { * }

sub gtk_level_bar_get_inverted(GtkWidget $level-bar)
    returns Bool
    is native(&gtk-lib)
    is export(:level-bar)
    { * }

sub gtk_level_bar_set_inverted(GtkWidget $level-bar, Bool $inverted)
    is native(&gtk-lib)
    is export(:level-bar)
    { * }

sub gtk_level_bar_get_max_value(GtkWidget $level-bar)
    returns num64
    is native(&gtk-lib)
    is export(:level-bar)
    { * }

sub gtk_level_bar_set_max_value(GtkWidget $level-bar, num64 $max-value)
    is native(&gtk-lib)
    is export(:level-bar)
    { * }

sub gtk_level_bar_get_min_value(GtkWidget $GTK_POLICY_AUTOMATIClevel-bar)
    returns num64
    is native(&gtk-lib)
    is export(:level-bar)
    { * }

sub gtk_level_bar_set_min_value(GtkWidget $level-bar, num64 $min-value)
    is native(&gtk-lib)
    is export(:level-bar)
    { * }

sub gtk_level_bar_get_mode(GtkWidget $level-bar)
    returns int32
    is native(&gtk-lib)
    is export(:level-bar)
    { * }

sub gtk_level_bar_set_mode(GtkWidget $level-bar, int32 $mode)
    is native(&gtk-lib)
    is export(:level-bar)
    { * }

sub gtk_level_bar_get_value(GtkWidget $level-bar)
    returns num64
    is native(&gtk-lib)
    is export(:level-bar)
    { * }

sub gtk_level_bar_set_value(GtkWidget $level-bar, num64 $value)
    is native(&gtk-lib)
    is export(:level-bar)
    { * }
#
# Scrolled Window
#
sub gtk_scrolled_window_new(Pointer $h-adjustment, Pointer $v-adjustment)
    returns GtkWidget
    is native(&gtk-lib)
    is export(:scrolled-window)
    { * }

sub gtk_scrolled_window_set_policy(GtkWidget $scrolled_window,
                                  int32 $h-bar-policy,
                                  int32 $v-bar-policy)
    is native(&gtk-lib)
    is export(:scrolled-window)
    { * }

#`{{
#--[ gtk_builder_ ]-------------------------------------------------------------
# GtkBuilder *gtk_builder_new (void);
sub gtk_builder_new ()
    returns GtkBuilder
    is native(&gtk-lib)
    is export
    { * }

# GtkBuilder *gtk_builder_new_from_string (const gchar *string, gssize length);
sub gtk_builder_new_from_file ( Str $glade-ui )
    returns GtkBuilder
    is native(&gtk-lib)
    is export
    { * }

# GtkBuilder *gtk_builder_new_from_string (const gchar *string, gssize length);
sub gtk_builder_new_from_string ( Str $glade-ui, uint32 $length)
    returns GtkBuilder
    is native(&gtk-lib)
    is export
    { * }

# guint gtk_builder_add_from_file(
#      GtkBuilder builder, const gchar *filename, GError **error);
sub gtk_builder_add_from_file (
    GtkBuilder $builder, Str $glade-ui, GError $error is rw
    ) returns int32
      is native(&gtk-lib)
      is export
      { * }

# guint gtk_builder_add_from_string ( GtkBuilder *builder,
#       const gchar *buffer, gsize length, GError **error);
sub gtk_builder_add_from_string (
    GtkBuilder $builder, Str $glade-ui, uint32 $size, GError $error is rw
    ) returns int32
      is native(&gtk-lib)
      is export
      { * }

# GObject *gtk_builder_get_object (
#      GtkBuilder *builder, const gchar *name);
sub gtk_builder_get_object (
    GtkBuilder $builder, Str $object-id
    ) returns GtkWidget
      is native(&gtk-lib)
      is export
      { * }
}}
#`{{
#--[ css style ]----------------------------------------------------------------
sub gtk_css_provider_new ( )
    returns GtkCssProvider
    is native(&gtk-lib)
    is export
    { * }

sub gtk_css_provider_get_named ( Str $name, Str $variant )
    returns GtkCssProvider
    is native(&gtk-lib)
    is export
    { * }

sub gtk_css_provider_load_from_path (
    GtkCssProvider $css_provider, Str $css-file, GError $error is rw
    ) is native(&gtk-lib)
      is export
      { * }

sub gtk_style_context_add_provider_for_screen (
    GdkScreen $screen, int32 $provider, int32 $priority
    ) is native(&gtk-lib)
      is export
      { * }
}}
#`{{ -> toplevel
#--[ dialog ]-------------------------------------------------------------------
# gint gtk_dialog_run (GtkDialog *dialog);
# GtkResponseType is an int32
sub gtk_dialog_run ( GtkWidget $dialog )
    returns int32
    is native(&gtk-lib)
    is export
    { * }

# void gtk_dialog_response (GtkDialog *dialog, gint response_id);
sub gtk_dialog_response ( GtkWidget $dialog, int32 $response_id )
    is native(&gtk-lib)
    is export
    { * }
}}

#--[ testing ]-----------------------------------------------------------------
#`{{
sub gdk_threads_add_idle (
  &function ( OpaquePointer $f_data ), OpaquePointer $data
  ) returns uint32
    is native(&gdk-lib)
    is export
    { * }

sub gdk_threads_add_idle_full (
  int32 $priority, &function ( OpaquePointer $f_data ),
  OpaquePointer $data, &notify ( )
  ) returns uint32
    is native(&gdk-lib)
    is export
    { * }
}}
#`[[[
sub gtk_test_init(CArray[int32] $argc, CArray[CArray[Str]] $argv)
    is native(&gtk-lib)
    is export
    { * }

#`{{
# $modifiers is a GdkModifierType
sub gtk_test_widget_send_key (
    GtkWidget $widget, int32 $keyval, uint32 $modifiers
    ) returns Bool
      is native(&gtk-lib)
      is export
      { * }
}}
#`{{
sub gtk_accel_group_get_modifier_mask ( GtkAccelGroup $accel_group )
    returns GdkModifierType
    is native(&gtk-lib)
    is export
    { * }
}}
]]]
