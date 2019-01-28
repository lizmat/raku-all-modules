use v6;
use NativeCall;

#use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
#use GTK::Glade::Native::Gdk;
#use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk/gtkenums.h
unit module GTK::Glade::Native::Gtk::Enums;

#-------------------------------------------------------------------------------
enum GtkOrientation is export <
  GTK_ORIENTATION_HORIZONTAL
  GTK_ORIENTATION_VERTICAL
>;

enum GtkScrollablePolicy is export <
  GTK_SCROLL_MINIMUM
  GTK_SCROLL_NATURAL
>;

enum GtkStateFlags is export (
  GTK_STATE_FLAG_NORMAL       => 0,
  GTK_STATE_FLAG_ACTIVE       => 1 +< 0,
  GTK_STATE_FLAG_PRELIGHT     => 1 +< 1,
  GTK_STATE_FLAG_SELECTED     => 1 +< 2,
  GTK_STATE_FLAG_INSENSITIVE  => 1 +< 3,
  GTK_STATE_FLAG_INCONSISTENT => 1 +< 4,
  GTK_STATE_FLAG_FOCUSED      => 1 +< 5,
  GTK_STATE_FLAG_BACKDROP     => 1 +< 6,
  GTK_STATE_FLAG_DIR_LTR      => 1 +< 7,
  GTK_STATE_FLAG_DIR_RTL      => 1 +< 8,
  GTK_STATE_FLAG_LINK         => 1 +< 9,
  GTK_STATE_FLAG_VISITED      => 1 +< 10,
  GTK_STATE_FLAG_CHECKED      => 1 +< 11,
  GTK_STATE_FLAG_DROP_ACTIVE  => 1 +< 12,
);

enum GtkRegionFlags is export (
  GTK_REGION_EVEN    => 1 +< 0,
  GTK_REGION_ODD     => 1 +< 1,
  GTK_REGION_FIRST   => 1 +< 2,
  GTK_REGION_LAST    => 1 +< 3,
  GTK_REGION_ONLY    => 1 +< 4,
  GTK_REGION_SORTED  => 1 +< 5,
);

enum  GtkJunctionSides is export (
  GTK_JUNCTION_NONE               => 0,
  GTK_JUNCTION_CORNER_TOPLEFT     => 1 +< 0,
  GTK_JUNCTION_CORNER_TOPRIGHT    => 1 +< 1,
  GTK_JUNCTION_CORNER_BOTTOMLEFT  => 1 +< 2,
  GTK_JUNCTION_CORNER_BOTTOMRIGHT => 1 +< 3,
  GTK_JUNCTION_TOP                => 1 +< 0 +| 1 +< 1,
  GTK_JUNCTION_BOTTOM             => 1 +< 2 +| 1 +< 3,
  GTK_JUNCTION_LEFT               => 1 +< 0 +| 1 +< 2,
  GTK_JUNCTION_RIGHT              => 1 +< 1 +| 1 +< 3,
);

enum GtkBorderStyle is export <
  GTK_BORDER_STYLE_NONE
  GTK_BORDER_STYLE_SOLID
  GTK_BORDER_STYLE_INSET
  GTK_BORDER_STYLE_OUTSET
  GTK_BORDER_STYLE_HIDDEN
  GTK_BORDER_STYLE_DOTTED
  GTK_BORDER_STYLE_DASHED
  GTK_BORDER_STYLE_DOUBLE
  GTK_BORDER_STYLE_GROOVE
  GTK_BORDER_STYLE_RIDGE
>;

enum GtkLevelBarMode is export <
  GTK_LEVEL_BAR_MODE_CONTINUOUS
  GTK_LEVEL_BAR_MODE_DISCRETE
>;

enum GtkInputPurpose is export <
  GTK_INPUT_PURPOS_FREE_FORM
  GTK_INPUT_PURPOSE_ALPHA
  GTK_INPUT_PURPOSE_DIGITS
  GTK_INPUT_PURPOSE_NUMBER
  GTK_INPUT_PURPOSE_PHONE
  GTK_INPUT_PURPOSE_URL
  GTK_INPUT_PURPOSE_EMAIL
  GTK_INPUT_PURPOSE_NAME
  GTK_INPUT_PURPOSE_PASSWORD
  GTK_INPUT_PURPOSE_PIN
>;

enum GtkInputHints is export (
  GTK_INPUT_HINT_NONE                => 0,
  GTK_INPUT_HINT_SPELLCHECK          => 1 +< 0,
  GTK_INPUT_HINT_NO_SPELLCHECK       => 1 +< 1,
  GTK_INPUT_HINT_WORD_COMPLETION     => 1 +< 2,
  GTK_INPUT_HINT_LOWERCASE           => 1 +< 3,
  GTK_INPUT_HINT_UPPERCASE_CHARS     => 1 +< 4,
  GTK_INPUT_HINT_UPPERCASE_WORDS     => 1 +< 5,
  GTK_INPUT_HINT_UPPERCASE_SENTENCES => 1 +< 6,
  GTK_INPUT_HINT_INHIBIT_OSK         => 1 +< 7,
  GTK_INPUT_HINT_VERTICAL_WRITING    => 1 +< 8,
  GTK_INPUT_HINT_EMOJI               => 1 +< 9,
  GTK_INPUT_HINT_NO_EMOJI            => 1 +< 10,
);

enum GtkPropagationPhase is export <
  GTK_PHASE_NONE
  GTK_PHASE_CAPTURE
  GTK_PHASE_BUBBLE
  GTK_PHASE_TARGET
>;

enum GtkEventSequenceState is export <
  GTK_EVENT_SEQUENCE_NONE
  GTK_EVENT_SEQUENCE_CLAIMED
  GTK_EVENT_SEQUENCE_DENIED
>;

enum GtkPanDirection is export <
  GTK_PAN_DIRECTION_LEFT
  GTK_PAN_DIRECTION_RIGHT
  GTK_PAN_DIRECTION_UP
  GTK_PAN_DIRECTION_DOWN
>;

enum GtkPopoverConstraint is export <
  GTK_POPOVER_CONSTRAINT_NONE
  GTK_POPOVER_CONSTRAINT_WINDOW
>;
