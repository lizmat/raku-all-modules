unit module X11::Xlib::Raw;

use NativeCall;
use NativeHelpers::CStruct;

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
constant XBool    is export := int32;


class XExtData is repr('CPointer') {}
class _XPrivate is repr('CPointer') {}
class _XrmHashBucketRec is repr('CPointer') {}
class XPointer is repr('CPointer') {}

class Display is repr('CStruct') {...};

#| Graphics Context
class GC is repr('CStruct') {};
    # XExtData *ext_data;   hook for extension to hang data
    # GContext gid;   protocol ID for graphics context
    #  there is more to this structure, but it is private to Xlib

class Visual is repr('CStruct') {};
# XExtData *ext_data;   hook for extension to hang data
# VisualID visualid;   visual id of this visual
# int class;     class of screen (monochrome, etc.)
# unsigned long red_mask, green_mask, blue_mask;   mask values
# int bits_per_rgb;   log base 2 of distinct color values
# int map_entries;   color map entries

class Depth is repr('CStruct') {};
# int depth;        this depth (Z) of the depth
# int nvisuals;     number of Visual types at this depth
# Visual *visuals;  list of visuals possible at this depth


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

class XEvent is repr('CUnion') is export {
  method gist {
    given $.type {
      when Expose { $!xexpose.gist }
    }
  }

  has int32 $.type;    #= type of event, see L<Event> enum
  # XAnyEvent xany;
  # XKeyEvent xkey;
  # XButtonEvent xbutton;
  # XMotionEvent xmotion;
  # XCrossingEvent xcrossing;
  # XFocusChangeEvent xfocus;
  HAS XExposeEvent $.xexpose;
  # XGraphicsExposeEvent xgraphicsexpose;
  # XNoExposeEvent xnoexpose;
  # XVisibilityEvent xvisibility;
  # XCreateWindowEvent xcreatewindow;
  # XDestroyWindowEvent xdestroywindow;
  # XUnmapEvent xunmap;
  # XMapEvent xmap;
  # XMapRequestEvent xmaprequest;
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
  # XErrorEvent xerror;
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
  has int32 $.width;
  has int32 $.height;          #= width and height of screen
  has int32 $.mwidth;
  has int32 $.mheight;         #= width and height of  in millimeters
  has int32 $.ndepths;         #= number of depths possible
  has Pointer[Depth] $.depths; #= list of allowable depths on the screen
  has int32 $.root_depth;      #= bits per pixel
  has Visual $.root_visual;    #= root visual
  has GC $.default_gc;         #= GC for the root root visual
  has Colormap $.cmap;         #= default color map
  has ulong $.white_pixel;
  has ulong $.black_pixel;     #= White and Black pixel values
  has int32 $.max_maps,
  has int32 $.min_maps;        #= max and min color maps
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

}

sub XOpenDisplay(
  Str # "host:display" connection string, pass blank string (C<''>) for default
) returns Display
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
