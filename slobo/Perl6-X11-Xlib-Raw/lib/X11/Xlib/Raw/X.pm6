# TODO: this actually is not tied to Xlib, should be moved up a namespace perhaps
unit package X11::Xlib::Raw::X;

enum XErrorCodes is export (
  Success             => 0, #= everything's okay
  BadRequest          => 1, #= bad request code
  BadValue            => 2, #= int parameter out of range
  BadWindow           => 3, #= parameter not a Window
  BadPixmap           => 4, #= parameter not a Pixmap
  BadAtom             => 5, #= parameter not an Atom
  BadCursor           => 6, #= parameter not a Cursor
  BadFont             => 7, #= parameter not a Font
  BadMatch            => 8, #= parameter mismatch
  BadDrawable         => 9, #= parameter not a Pixmap or Window

  #| depending on context:
  #|   - key/button already grabbed
  #|   - attempt to free an illegal cmap entry
  #|   - attempt to store into a read-only color map entry.
  #|   - attempt to modify the access control list from other than the local host.
  BadAccess           => 10,

  BadAlloc            => 11, #= insufficient resources
  BadColor            => 12, #= no such colormap
  BadGC               => 13, #= parameter not a GC
  BadIDChoice         => 14, #= choice not in range or already used
  BadName             => 15, #= font or color name doesn't exist
  BadLength           => 16, #= Request length incorrect
  BadImplementation   => 17, #= server is defective

  FirstExtensionError => 128,
  LastExtensionError  => 255,

);

#| Key masks. Used as modifiers to GrabButton and GrabKey, results of QueryPointer,
#| state in various key-, mouse-, and button-related events.
enum KeyMasks is export (
  ShiftMask   => 1 +< 0,
  LockMask    => 1 +< 1,
  ControlMask => 1 +< 2,
  Mod1Mask    => 1 +< 3,
  Mod2Mask    => 1 +< 4,
  Mod3Mask    => 1 +< 5,
  Mod4Mask    => 1 +< 6,
  Mod5Mask    => 1 +< 7,
);

#| button names. Used as arguments to GrabButton and as detail in ButtonPress
#| and ButtonRelease events.  Not to be confused with button masks above.
#| Note that 0 is already defined above as "AnyButton".
enum ButtonNames is export (
  Button1 => 1,
  Button2 => 2,
  Button3 => 3,
  Button4 => 4,
  Button5 => 5,
);

#| GrabPointer, GrabButton, GrabKeyboard, GrabKey Modes
enum GrabModes is export (
  GrabModeSync  => 0,
  GrabModeAsync => 1,
);
