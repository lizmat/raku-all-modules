unit module X11::Xlib::Raw;

use NativeCall;
use NativeHelpers::CStruct;
use X11::Xlib::Raw::X;
use X11::Xlib::Raw::Xproto;

sub libX11 {
  $*VM.config<os> eq 'darwin'
    # for OSX, XQuartz is installed in /opt and not in search path
    ?? '/opt/X11/lib/libX11.dylib'
    # for rest, just ask the system
    !! $*VM.platform-library-name('X11'.IO).Str
}

constant XID      is export := ulong;
constant Window   is export := XID;
constant Colormap is export := XID;
constant Drawable is export := XID;
constant GContext is export := XID;
constant Cursor   is export := XID;
constant VisualID is export := int32;
constant XBool    is export := int32;
constant Status   is export := int32;
constant Atom     is export := int32;
constant Time     is export := int32;
constant KeyCode  is export := uint8;
constant KeySym   is export := XID;

class XPointer is repr('CPointer') {}

#| XExtData structure; Extensions need a way to hang private data on some structures.
class XExtData is repr('CStruct') {
	has int32 $.number;          #= number returned by XRegisterExtension
	has XExtData $.next;         #= next item on list of data for structure
  has Pointer $!free_private;  #= called to free private storage
	              # &callback... int (*free_private)(	struct _XExtData *extension);
	has XPointer $.private_data; #= data private to this extension
}

class _XPrivate is repr('CPointer') {}
class _XrmHashBucketRec is repr('CPointer') {}

class Display is repr('CStruct') {...};

#| Graphics Context structure
#| The contents of this structure are implementation
#| dependent.  A GC should be treated as opaque by application code.
class GC is repr('CStruct') {
  has XExtData $.ext_data;  #= hook for extension to hang data
  has GContext $.gid;       #= protocol ID for graphics context
  #  there is more to this structure, but it is private to Xlib
}

#| Visual structure; contains information about colormapping possible.
class Visual is repr('CStruct') {
  has XExtData $.ext_data;  #= hook for extension to hang data
  has VisualID $.visualid;  #= visual id of this visual
  has int32 $.class;        #= class of screen (monochrome, etc.)
  has ulong $.red_mask;     #= red channel mask value
  has ulong $.green_mask;   #= green channel mask value
  has ulong $.blue_mask;    #= blue channel mask value
  has int32 $.bits_per_rgb; #= log base 2 of distinct color values
  has int32 $.map_entries;  #= color map entries
}

#| Depth structure; contains information for each possible depth.
class Depth is repr('CStruct') {
  has int32 $.depth;              #= this depth (Z) of the depth
  has int32 $.nvisuals;           #= number of Visual types at this depth
  has Pointer[Visual] $.visuals;  #= list of visuals possible at this depth
}


class XExposeEvent is repr('CStruct') {
  method gist {
    "XExposeEvent #$.serial Window $.window {$.width}x{$.height}@($.x,$.y) {$.send_event ?? 'from SendEvent' !! ''}"
  }
  has int32 $.type;
  has ulong $.serial;     #= # of last request processed by server
  has XBool $.send_event; #= true if this came from a SendEvent request
  has Display $.display;  #= Display the event was read from
  has Window $.window;
  has int32 $.x;
  has int32 $.y;
  has int32 $.width;
  has int32 $.height;
  has int32 $.count;      #= if non-zero, at least this many more
};

class XErrorEvent is repr('CStruct') {
  method gist {
    my $error   = X11::Xlib::Raw::X::XErrorCodes($.error_code);
    my $request = X11::Xlib::Raw::Xproto::RequestCodes($.request_code);
    "XErrorEvent: $.error_code - $error for $.request_code:$.minor_code - $request on Resource ID $.resourceid"
  }

  has int32 $.type;
  has Display $.display;    #= Display the event was read from
  has XID $.resourceid;     #= resource id
  has ulong $.serial;       #= # of last request processed by server
  has uint8 $.error_code;   #= error code of failed request
  has uint8 $.request_code; #= Major op-code of failed request
  has uint8 $.minor_code;   #= Minor op-code of failed request
}

#| Event names. Used in "type" field in XEvent structures.
enum Event is export (
  KeyPress         => 2,
  KeyRelease       => 3,
  ButtonPress      => 4,
  ButtonRelease    => 5,
  MotionNotify     => 6,
  EnterNotify      => 7,
  LeaveNotify      => 8,
  FocusIn          => 9,
  FocusOut         => 10,
  KeymapNotify     => 11,
  Expose           => 12,
  GraphicsExpose   => 13,
  NoExpose         => 14,
  VisibilityNotify => 15,
  CreateNotify     => 16,
  DestroyNotify    => 17,
  UnmapNotify      => 18,
  MapNotify        => 19,
  MapRequest       => 20,
  ReparentNotify   => 21,
  ConfigureNotify  => 22,
  ConfigureRequest => 23,
  GravityNotify    => 24,
  ResizeRequest    => 25,
  CirculateNotify  => 26,
  CirculateRequest => 27,
  PropertyNotify   => 28,
  SelectionClear   => 29,
  SelectionRequest => 30,
  SelectionNotify  => 31,
  ColormapNotify   => 32,
  ClientMessage    => 33,
  MappingNotify    => 34,
  GenericEvent     => 35,
  LASTEvent        => 36,
);


class XKeyEvent is repr('CStruct') {
  method gist {
    "XKeyEvent #$.serial@$.time Window $.window @($.x,$.y) Root $.root @($.x_root,$.y_root) SubWindow $.subwindow State {sprintf("%b", $.state)} KeyCode $.keycode SameScreen: $.same_screen {$.send_event ?? 'from SendEvent' !! ''}"
  }
  has int32 $.type;
  has ulong $.serial;      #= # of last request processed by server
  has XBool $.send_event;  #= true if this came from a SendEvent request
  has Display $.display;   #= Display the event was read from
  has Window $.window;     #= "event" window it is reported relative to
  has Window $.root;       #= root window that the event occurred on
  has Window $.subwindow;  #= child window
  has Time $.time;         #= milliseconds
  has int32 $.x;           #= pointer x coordinate in event window
  has int32 $.y;           #= pointer y coordinate in event window
  has int32 $.x_root;      #= pointer x coordinate relative to root
  has int32 $.y_root;      #= pointer y coordinate relative to root
  has uint32 $.state;      #= key or button mask
  has uint32 $.keycode;    #= detail
  has XBool $.same_screen; #= same screen flag
};

class XButtonEvent is repr('CStruct') {
  method gist {
    "XButtonEvent #$.serial Window $.window @($.x,$.y) Root $.root @($.x_root,$.y_root) SubWindow $.subwindow State $.state Button $.button SameScreen: $.same_screen {$.send_event ?? 'from SendEvent' !! ''}"
  }
  has int32 $.type;
  has ulong $.serial;      #= # of last request processed by server
  has XBool $.send_event;  #= true if this came from a SendEvent request
  has Display $.display;   #= Display the event was read from
  has Window $.window;     #= "event" window it is reported relative to
  has Window $.root;       #= root window that the event occurred on
  has Window $.subwindow;  #= child window
  has Time $.time;         #= milliseconds
  has int32 $.x;           #= pointer x coordinate in event window
  has int32 $.y;           #= pointer y coordinate in event window
  has int32 $.x_root;      #= pointer x coordinate relative to root
  has int32 $.y_root;      #= pointer y coordinate relative to root
  has uint32 $.state;      #= key or button mask
  has uint32 $.button;     #= detail
  has XBool $.same_screen; #= same screen flag
};


class XUnmapEvent is repr('CStruct') {
  method gist {
    "XUnmapEvent #$.serial Event $.event Window $.window {$.send_event ?? 'from SendEvent' !! ''}"
  }
  has int32 $.type;
  has ulong $.serial;     #= # of last request processed by server
  has XBool $.send_event; #= true if this came from a SendEvent request
  has Display $.display;  #= Display the event was read from
  has Window $.event;
  has Window $.window;
  has XBool $.from_configure;
};

class XMapRequestEvent is repr('CStruct') {
  method gist {
    "XMapRequestEvent #$.serial Parent $.parent Window $.window {$.send_event ?? 'from SendEvent' !! ''}"
  }
  has int32 $.type;
  has ulong $.serial;     #= # of last request processed by server
  has XBool $.send_event; #= true if this came from a SendEvent request
  has Display $.display;  #= Display the event was read from
  has Window $.parent;
  has Window $.window;
};


class XEvent is repr('CUnion') is export {
  method gist {
    given $.type {
      when KeyPress { $!xkey.gist }
      when KeyRelease { $!xkey.gist }
      when ButtonPress { $!xbutton.gist }
      when ButtonRelease { $!xbutton.gist }
      when Expose { $!xexpose.gist }
      when UnmapNotify { $!xunmap.gist }
      when MapRequest { $!xmaprequest.gist }
      default {
        my $event_name = Event($.type);
        "Xlib::Raw Unimplemented Type: $.type - $event_name";
      }
    }
  }

  has int32 $.type;    #= type of event, see L<Event> enum
  # XAnyEvent xany;
  HAS XKeyEvent $.xkey;
  HAS XButtonEvent $.xbutton;
  # XMotionEvent xmotion;
  # XCrossingEvent xcrossing;
  # XFocusChangeEvent xfocus;
  HAS XExposeEvent $.xexpose;
  # XGraphicsExposeEvent xgraphicsexpose;
  # XNoExposeEvent xnoexpose;
  # XVisibilityEvent xvisibility;
  # XCreateWindowEvent xcreatewindow;
  # XDestroyWindowEvent xdestroywindow;
  HAS XUnmapEvent $.xunmap;
  # XMapEvent xmap;
  HAS XMapRequestEvent $.xmaprequest;
  # XReparentEvent xreparent;
  # XConfigureEvent xconfigure;
  # XGravityEvent xgravity;
  # XResizeRequestEvent xresizerequest;
  # XConfigureRequestEvent xconfigurerequest;
  # XCirculateEvent xcirculate;
  # XCirculateRequestEvent xcirculaterequest;
  # XPropertyEvent xproperty;
  # XSelectionClearEvent xselectionclear;
  # XSelectionRequestEvent xselectionrequest;
  # XSelectionEvent xselection;
  # XColormapEvent xcolormap;
  # XClientMessageEvent xclient;
  # XMappingEvent xmapping;
  HAS XErrorEvent $.xerror;
  # XKeymapEvent xkeymap;
  # XGenericEvent xgeneric;
  # XGenericEventCookie xcookie;

  # horrible hack to size the XEvent struct
  class Padding24 is repr('CStruct') {
    has long $.pad01; has long $.pad02; has long $.pad03; has long $.pad04;
    has long $.pad05; has long $.pad06; has long $.pad07; has long $.pad08;
    has long $.pad09; has long $.pad10; has long $.pad11; has long $.pad12;
    has long $.pad13; has long $.pad14; has long $.pad15; has long $.pad16;
    has long $.pad17; has long $.pad18; has long $.pad19; has long $.pad20;
    has long $.pad21; has long $.pad22; has long $.pad23; has long $.pad24;
  };
  HAS Padding24 $!pad; # long pad[24];
};

#| Screen struct
class Screen is repr('CStruct') is export {
  has XExtData $.ext_data;     #= hook for extension to hang data
  has Display $.display;       #= back pointer to display structure
  has Window $.root;           #= Root window id.
  has int32 $.width;           #= width of screen
  has int32 $.height;          #= height of screen
  has int32 $.mwidth;          #= width of screen in millimeters
  has int32 $.mheight;         #= height of screen  in millimeters
  has int32 $.ndepths;         #= number of depths possible
  has Pointer[Depth] $.depths; #= list of allowable depths on the screen
  has int32 $.root_depth;      #= bits per pixel
  has Visual $.root_visual;    #= root visual
  has GC $.default_gc;         #= GC for the root root visual
  has Colormap $.cmap;         #= default color map
  has ulong $.white_pixel;     #= White pixel value
  has ulong $.black_pixel;     #= Black pixel value
  has int32 $.max_maps,        #= max color maps
  has int32 $.min_maps;        #= min color maps
  has int32 $.backing_store;   #= Never, WhenMapped, Always
  has int32 $.save_unders;
  has long $.root_input_mask;  #= initial root input mask
}

class ScreenFormat is repr('CStruct') {
  has XExtData $.ext_data;    #= hook for extension to hang data
  has int32 $.depth;          #= depth of this image format
  has int32 $.bits_per_pixel; #= bits/pixel at this depth
  has int32 $.scanline_pad;   #= scanline must padded to this multiple
}


class Display {
  has XExtData $.ext_data;         #=  hook for extension to hang data
  has _XPrivate $!private1;
  has int32 $.fd;                  #= Network socket.
  has int32 $!private2;
  has int32 $.proto_major_version; #= major version of server's X protocol
  has int32 $.proto_minor_version; #= minor version of servers X protocol
  has Str $.vendor;                #= vendor of the server hardware
  has ulong $!private3;
  has ulong $!private4;
  has ulong $!private5;
  has int32 $!private6;
  has Pointer[void] $.resource_alloc; #= &callback(Display --> ulong)   allocator function
  has int32 $.byte_order;          #= screen byte order, LSBFirst, MSBFirst
  has int32 $.bitmap_unit;         #= padding and data requirements
  has int32 $.bitmap_pad;          #= padding requirements on bitmaps
  has int32 $.bitmap_bit_order;    #= LeastSignificant or MostSignificant
  has int32 $.nformats;            #= number of pixmap formats in list
  has ScreenFormat $.pixmap_format; #= pixmap format list
  has int32 $!private8;
  has int32 $.release;            #= release of the server
  has _XPrivate $!private9;
  has _XPrivate $!private10;
  has int32 $.qlen;               #= Length of input event queue
  has ulong $.last_request_read;  #= seq number of last event read
  has ulong $.request;            #= sequence number of last request.
  has XPointer $!private11;
  has XPointer $!private12;
  has XPointer $!private13;
  has XPointer $!private14;
  has uint32 $.max_request_size;  #= maximum number 32 bit words in request
  has _XrmHashBucketRec $.db;
  has Pointer[void] $!private15;  #= &callback(Display --> int)
  has Str $.display_name;         #= "host:display" string used on this connect
  has int32 $.default_screen;     #= default screen for operations
  has int32 $.nscreens;           #= number of screens on this server
  has Pointer[Screen] $!pscreens; #= pointer to list of screens
  has ulong $.motion_buffer;      #= size of motion buffer
  has ulong $!private16;
  has int32 $.min_keycode;        #= minimum defined keycode
  has int32 $.max_keycode;        #= maximum defined keycode
  has XPointer $!private17;
  has XPointer $!private18;
  has int32 $!private19;
  has Str $.xdefaults;
  #  there is more to this structure, but it is private to Xlib

  method DefaultScreen() { $.default_screen }
  method screens() {
    state $screens = LinearArray[Screen].new-from-pointer(size => $.nscreens, ptr => $!pscreens);
    return $screens;
  }
  method ScreenOfDisplay($scr) { $.screens[$scr]; }
  method RootWindow($scr) { $.ScreenOfDisplay($scr).root }
  method BlackPixel($scr) { $.ScreenOfDisplay($scr).black_pixel }
  method WhitePixel($scr) { $.ScreenOfDisplay($scr).white_pixel }
  method DefaultGC($scr)  { $.ScreenOfDisplay($scr).default_gc }

  method DefaultRootWindow() { $.RootWindow($.DefaultScreen) }


}

class XWindowAttributes is repr('CStruct') is export {
  has int32 $.x;
  has int32 $.y;			#= location of window
  has int32 $.width;
  has int32 $.height;		#= width and height of window
  has int32 $.border_width;		#= border width of window
  has int32 $.depth;          	#= depth of window
  has Visual $.visual;		#= the associated visual structure
  has Window $.root;        	#= root of screen containing window
  has int32 $.class;			#= InputOutput, InputOnly
  has int32 $.bit_gravity;		#= one of bit gravity values
  has int32 $.win_gravity;		#= one of the window gravity values
  has int32 $.backing_store;		#= NotUseful, WhenMapped, Always
  has ulong $.backing_planes;#= planes to be preserved if possible
  has ulong $.backing_pixel;#= value to be used when restoring planes
  has XBool $.save_under;		#= boolean, should bits under be saved?
  has Colormap $.colormap;		#= color map to be associated with window
  has XBool $.map_installed;		#= boolean, is color map currently installed
  has int32 $.map_state;		#= IsUnmapped, IsUnviewable, IsViewable
  has long $.all_event_masks;	#= set of events all people have interest in
  has long $.your_event_mask;	#= my event mask
  has long $.do_not_propagate_mask; #= set of events that should not propagate
  has XBool $.override_redirect;	#= boolean value for override-redirect
  has Screen $.screen;		#= back pointer to correct screen
}

#| new structure for manipulating TEXT properties; used with WM_NAME,
#| WM_ICON_NAME, WM_CLIENT_MACHINE, and WM_COMMAND.
class XTextProperty is repr('CStruct') is export {
  has Str $.value;     #= same as Property routines
  has Atom $.encoding; #= prop type
  has int32 $.format;  #= prop data format: 8, 16, or 32
  has ulong $.nitems;  #= number of data items in value
}

class XClassHint is repr('CStruct') is export {
	has Str $.res_name;
	has Str $.res_class;
};

sub XGetClassHint(
    Display,		# display
    Window,     # w
    XClassHint,	# class_hints_return
) returns Status
  is native(&libX11)
  is export
  { * }

sub XGetWMName(
    Display,		# display
    Window,     # w
    XTextProperty,	# text_prop_return
) returns Status
  is native(&libX11)
  is export
  { * }


sub XRaiseWindow(
    Display, # display
    Window   # w
) returns int32
  is native(&libX11)
  is export
  { * }

sub XOpenDisplay(
  Str # "host:display" connection string, pass blank string (C<''>) for default
) returns Display
  is native(&libX11)
  is export
  { * }

sub XDisplayName(
  Str # "host:display" connection string, pass blank string (C<''>) for default
) returns Str
  is native(&libX11)
  is export
  { * }

sub XDisplayString(
  Display # display
) returns Str
  is native(&libX11)
  is export
  { * }

sub XSetInputFocus(
    Display, # display
    Window,  # w
    int32,   # revert_to
    Time,    # time
) returns int32
  is native(&libX11)
  is export
  { * }

sub XSync(
  Display, # display
  XBool    # discard
) returns int32
  is native(&libX11)
  is export
  { * }

sub XCreateSimpleWindow(
    Display, # display
    Window,  # parent
    int32,   # x
    int32,   # y
    uint32,  # width
    uint32,  # height
    uint32,  # border_width
    ulong,   # border
    ulong    # background
) returns Window
  is native(&libX11)
  is export
  { * }

sub XMapWindow(
    Display, # display
    Window   # window
) returns int32
  is native(&libX11)
  is export
  { * }

sub XSelectInput(
    Display, # display
    Window,  # window
    long     # event_mask
) returns int32
  is native(&libX11)
  is export
  { * }

sub XNextEvent(
    Display, # display
    XEvent,  # event_return
) returns int32
  is native(&libX11)
  is export
  { * }

sub XCloseDisplay(
    Display, # display
) returns int32
  is native(&libX11)
  is export
  { * }


sub XGrabButton( Display, uint32 $button, uint32 $modifiers, Window $grab_window,
  XBool $owner_events, uint32 $event_mask, int32 $pointer_mode, int32 $keyboard_mode,
  Window $confine_to, Cursor ) returns int32
  is native(&libX11) is export { * }

sub XGrabKey( Display, int32 $keycode, uint32 $modifiers, Window $grab_window,
  XBool $owner_events, int32 $pointer_mode, int32 $keyboard_mode ) returns int32
  is native(&libX11) is export { * }

sub XGrabServer( Display ) returns int32
  is native(&libX11) is export { * }

sub XUngrabServer( Display ) returns int32
  is native(&libX11) is export { * }

sub XAddToSaveSet( Display, Window ) returns int32
  is native(&libX11) is export { * }

sub XRemoveFromSaveSet( Display, Window ) returns int32
  is native(&libX11) is export { * }

sub XReparentWindow( Display, Window $w, Window	$parent, int32 $x, int32 $y ) returns int32
  is native(&libX11) is export { * }

sub XDestroyWindow( Display, Window ) returns int32
  is native(&libX11) is export { * }

sub XUnmapWindow( Display, Window ) returns int32
  is native(&libX11) is export { * }

sub XFillRectangle(
    Display,  # display
    Drawable, # drawable
    GC,       # gc
    int32,    # x
    int32,    # y
    uint32,   # width
    uint32,   # height
) returns int32
  is native(&libX11)
  is export
  { * }

sub XDrawString(
    Display,  # display
    Drawable, # d
    GC,       # gc
    int32,    # x
    int32,    # y
    Str,      # string
    int32     # length
) returns int32
  is native(&libX11)
  is export
  { * }


sub XQueryTree(
    Display,       # display
    Window,        # root window
    Window is rw,  # root_return
    Window is rw,  # parent_return
    Pointer is rw, # children_return
    uint32 is rw   # nchildren_return
) returns Status
  is native(&libX11)
  is export
  { * }


sub XGetWindowAttributes(
    Display,          # display
    Window,           # w
    XWindowAttributes # window_attributes_return
) returns Status
  is native(&libX11)
  is export
  { * }


sub XSetErrorHandler(
  &handler ( Display, XErrorEvent --> int32 )
) returns int32
  is native(&libX11)
  is export
  { * }

sub XGetErrorText( Display, int32 $code, Str $buffer_return is rw, int32 $length ) returns int32
  is native(&libX11) is export { * }

sub XKeysymToKeycode( Display, KeySym ) returns KeyCode
  is native(&libX11) is export { * }

sub XFree( Pointer[void] ) returns int32
  is native(&libX11) is export { * }

enum XEventMask is export (
  NoEventMask               =>      0,
  KeyPressMask              => 1 +< 0,
  KeyReleaseMask            => 1 +< 1,
  ButtonPressMask           => 1 +< 2,
  ButtonReleaseMask         => 1 +< 3,
  EnterWindowMask           => 1 +< 4,
  LeaveWindowMask           => 1 +< 5,
  PointerMotionMask         => 1 +< 6,
  PointerMotionHintMask     => 1 +< 7,
  Button1MotionMask         => 1 +< 8,
  Button2MotionMask         => 1 +< 9,
  Button3MotionMask         => 1 +< 10,
  Button4MotionMask         => 1 +< 11,
  Button5MotionMask         => 1 +< 12,
  ButtonMotionMask          => 1 +< 13,
  KeymapStateMask           => 1 +< 14,
  ExposureMask              => 1 +< 15,
  VisibilityChangeMask      => 1 +< 16,
  StructureNotifyMask       => 1 +< 17,
  ResizeRedirectMask        => 1 +< 18,
  SubstructureNotifyMask    => 1 +< 19,
  SubstructureRedirectMask  => 1 +< 20,
  FocusChangeMask           => 1 +< 21,
  PropertyChangeMask        => 1 +< 22,
  ColormapChangeMask        => 1 +< 23,
  OwnerGrabButtonMask       => 1 +< 24,
);


#| Used in GetWindowAttributes reply
enum WindowMapState is export (
  IsUnmapped   =>	0,
  IsUnviewable =>	1,
  IsViewable  =>	2,
);

#| Used in SetInputFocus, GetInputFocus
enum FocusAtoms is export (
  RevertToNone        => 0,
  RevertToPointerRoot => 1,
  RevertToParent      => 2,
);

#| RESERVED RESOURCE AND CONSTANT DEFINITIONS
enum ReservedAtoms is export (
  None            => 0, #=	universal null resource or null atom
  ParentRelative  => 1, #=	background pixmap in CreateWindow and ChangeWindowAttributes
  CopyFromParent  => 0, #=	border pixmap in CreateWindow and ChangeWindowAttributes special VisualID and special window class passed to CreateWindow
  PointerWindow   => 0, #=	destination window in SendEvent
  InputFocus      => 1, #=	destination window in SendEvent
  PointerRoot     => 1, #=	focus window in SetInputFocus
  AnyPropertyType => 0, #=	special Atom, passed to GetProperty
  AnyKey          => 0, #=	special Key Code, passed to GrabKey
  AnyButton       => 0, #=	special Button Code, passed to GrabButton
  AllTemporary    => 0, #=	special Resource ID passed to KillClient
  CurrentTime     => 0, #=	special Time
  NoSymbol        => 0, #=	special KeySym
);
