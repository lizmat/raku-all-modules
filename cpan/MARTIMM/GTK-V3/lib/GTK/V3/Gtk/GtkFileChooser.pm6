use v6;
use NativeCall;

use GTK::V3::X;
use GTK::V3::N::NativeLib;
use GTK::V3::Glib::GObject;
use GTK::V3::Glib::GInterface;
use GTK::V3::Glib::GSList;
#use GTK::V3::Gtk::GtkFileFilter;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkfilechooser.h
# https://developer.gnome.org/gtk3/stable/GtkFileChooser.html
unit class GTK::V3::Gtk::GtkFileChooser:auth<github:MARTIMM>
  is GTK::V3::Glib::GInterface;

#-------------------------------------------------------------------------------
enum GtkFileChooserAction is export <
  GTK_FILE_CHOOSER_ACTION_OPEN
  GTK_FILE_CHOOSER_ACTION_SAVE
  GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER
  GTK_FILE_CHOOSER_ACTION_CREATE_FOLDER
>;

enum GtkFileChooserConfirmation is export <
  GTK_FILE_CHOOSER_CONFIRMATION_CONFIRM
  GTK_FILE_CHOOSER_CONFIRMATION_ACCEPT_FILENAME
  GTK_FILE_CHOOSER_CONFIRMATION_SELECT_AGAIN
>;

enum GtkFileChooserError <
  GTK_FILE_CHOOSER_ERROR_NONEXISTENT
  GTK_FILE_CHOOSER_ERROR_BAD_FILENAME
  GTK_FILE_CHOOSER_ERROR_ALREADY_EXISTS
  GTK_FILE_CHOOSER_ERROR_INCOMPLETE_HOSTNAME
>;

#-------------------------------------------------------------------------------
#TODO notes free lists

sub gtk_file_chooser_set_action (
  N-GObject $chooser, int32 $file-chooser-action
) is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_action ( N-GObject $chooser )
  returns int32
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_local_only (
  N-GObject $chooser, Bool $local_only
) is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_local_only ( N-GObject $chooser )
  returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_select_multiple (
  N-GObject $chooser, Bool $select_multiple
) is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_select_multiple ( N-GObject $chooser )
  returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_show_hidden ( N-GObject $chooser, Bool $show_hidden )
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_show_hidden ( N-GObject $chooser )
  returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_do_overwrite_confirmation (
  N-GObject $chooser, Bool $do_overwrite_confirmation
) is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_do_overwrite_confirmation ( N-GObject $chooser )
  returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_create_folders (
  N-GObject $chooser, Bool $create_folders
) is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_create_folders ( N-GObject $chooser )
  returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_current_name ( N-GObject $chooser, Str $name )
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_current_name ( N-GObject $chooser )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_filename ( N-GObject $chooser )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_filename ( N-GObject $chooser, Str $filename )
  returns Bool # not useful
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_select_filename ( N-GObject $chooser, Str $filename )
  returns Bool # not useful
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_unselect_filename ( N-GObject $chooser, Str $filename )
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_select_all ( N-GObject $chooser )
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_unselect_all ( N-GObject $chooser )
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_filenames ( N-GObject $chooser )
  returns N-GSList
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_current_folder ( N-GObject $chooser, Str $filename )
  returns Bool # not useful
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_current_folder ( N-GObject $chooser )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_uri ( N-GObject $chooser )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_uri ( N-GObject $chooser, Str $uri )
  returns Bool # not useful
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_select_uri ( N-GObject $chooser, Str $uri )
  returns Bool # not useful
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_unselect_uri ( N-GObject $chooser, Str $uri )
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_uris ( N-GObject $chooser )
  returns N-GSList
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_current_folder_uri ( N-GObject $chooser, Str $uri )
  returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_current_folder_uri ( N-GObject $chooser )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_preview_widget (
  N-GObject $chooser, N-GObject $preview_widget
) is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_preview_widget ( N-GObject $chooser )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_preview_widget_active (
  N-GObject $chooser, Bool $active
) is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_preview_widget_active ( N-GObject $chooser )
  returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_use_preview_label (
  N-GObject $chooser, Bool $use_label
) is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_use_preview_label ( N-GObject $chooser )
  returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_preview_filename ( N-GObject $chooser )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_preview_uri ( N-GObject $chooser )
  returns Str
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_extra_widget (
  N-GObject $chooser, N-GObject $extra_widget
) is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_extra_widget ( N-GObject $chooser )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_add_filter ( N-GObject $chooser, N-GObject $filefilter )
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_remove_filter ( N-GObject $chooser, N-GObject $filefilter)
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_list_filters ( N-GObject $chooser )
  returns N-GSList
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_filter ( N-GObject $chooser, N-GObject $filter )
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_filter ( N-GObject $chooser )
  returns N-GObject # GtkFileFilter
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_add_shortcut_folder (
  N-GObject $chooser, Str $folder, OpaquePointer
) returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_remove_shortcut_folder (
  N-GObject $chooser, Str $folder, OpaquePointer
) returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_list_shortcut_folders ( N-GObject $chooser )
  returns N-GSList
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_add_shortcut_folder_uri (
   N-GObject $chooser, Str $uri, OpaquePointer
) returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_remove_shortcut_folder_uri (
  N-GObject $chooser, Str $uri, OpaquePointer
) returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_list_shortcut_folder_uris ( N-GObject $chooser )
  returns N-GSList
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_current_folder_file ( N-GObject $chooser )
  returns N-GObject # GFile
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_file ( N-GObject $chooser )
  returns N-GObject # GFile
  is native(&gtk-lib)
  { * }

# GObject::g_object_unref
# GSList::G_slist_free
sub gtk_file_chooser_get_files (  N-GObject $chooser )
  returns N-GSList
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_get_preview_file ( N-GObject $chooser )
  returns N-GObject # GFile
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_select_file (
  N-GObject $chooser, N-GObject $file, OpaquePointer
) returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_current_folder_file (
  N-GObject $chooser, N-GObject $file, OpaquePointer
) returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_set_file (
  N-GObject $chooser, N-GObject $file, OpaquePointer
) returns Bool
  is native(&gtk-lib)
  { * }

sub gtk_file_chooser_unselect_file ( N-GObject $chooser, N-GObject $file )
  is native(&gtk-lib)
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( *%options ) {

  # prevent creating wrong widgets
  return unless self.^name eq 'GTK::V3::Gtk::GtkFileChooser';

  if ? %options<widget> || %options<build-id> {
    # provided in GObject
  }

  elsif %options.keys.elems {
    die X::GTK::V3.new(
      :message('Unsupported options for ' ~ self.^name ~
               ': ' ~ %options.keys.join(', ')
              )
    );
  }
}

#-------------------------------------------------------------------------------
method fallback ( $native-sub is copy --> Callable ) {

  my Callable $s;
  try { $s = &::($native-sub); }
  try { $s = &::("gtk_file_chooser_$native-sub"); } unless ?$s;

  $s = callsame unless ?$s;

  $s;
}
