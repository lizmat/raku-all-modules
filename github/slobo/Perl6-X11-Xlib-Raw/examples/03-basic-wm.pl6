# basic_wm example ported from https://github.com/jichu4n/basic_wm
use X11::Xlib::Raw;

use NativeCall;
use NativeHelpers::Pointer;
use X11::Xlib::Raw::X;
use X11::Xlib::Raw::keysym;

class WindowManager { ... };

sub MAIN {
  my $display = XOpenDisplay("") or die 'Cannot open display';

  WindowManager.new(display => $display).run;
}

class WindowManager {
  has X11::Xlib::Raw::Display $.display;
  has %!clients;

  method run {
    $.become-wm or exit 1;

    $.set-error-handler;

    $.frame-existing-windows;

    $.event-loop;
  }

  method become-wm {
    note "Requesting to become WM on " ~ XDisplayName("");
    my Bool $another_wm_detected;

    # Temporary error handler while we attempt to become WM for this display
    XSetErrorHandler(-> $disp, $error {
      # In the case of an already running window manager, the error code from
      # XSelectInput is BadAccess. We don't expect this handler to receive any
      # other errors.
      $error.error_code == BadAccess or note "Unexpected error";

      note "Got error while requesting to become WM: " ~ $error.gist;
      $another_wm_detected = True;
    } );

    # Stake the claim on needed events
    XSelectInput($.display, $.display.DefaultRootWindow, SubstructureRedirectMask +| SubstructureNotifyMask);

    # Since Xlib buffers requests, we need to manually sync to see if XSelectInput succeeded
    XSync($.display, False);

    if $another_wm_detected {
      note "Detected another window manager on display " ~ XDisplayString($.display);
      return False;
    } else {
      note "Ok, We are the WM";
      return True;
    }
  }

  method set-error-handler {
    # Just dump any errors to console
    XSetErrorHandler(-> $disp, $error {
      note "Got error: " ~ $error.gist;
      return 0; # ignored anyways
    } );
  }

  method frame-existing-windows {
    # 1. Grab X server to prevent windows from changing under us.
    XGrabServer($.display);

    # 2. Reparent existing top-level windows.
    # i. Query existing top-level windows.

    my $top_level_windows := Pointer[Window].new;

    XQueryTree($.display, $.display.DefaultRootWindow, my Window $root_return, my Window $parent, $top_level_windows, my uint32 $num_top_level_windows);

    # ii. Frame each top-level window.
    for 0..^$num_top_level_windows -> $i {
      my $window = ($top_level_windows + $i).deref;
      $.frame( $$window );
    }

    # ii. Free top-level window array.
    XFree($top_level_windows);

    # 3. Ungrab X server.
    XUngrabServer($.display);
  }

  method frame(Window $w) {
    note "Framing $w";

    # Visual properties of the frame to create.
    constant BORDER_WIDTH = 3;
    constant BORDER_COLOR = 0xff0000;
    constant BG_COLOR = 0x0000ff;

    if %!clients{ $w }:exists {
      note "Already have a frame for $w";
      return;
    }

    # 1. Retrieve attributes of window to frame.
    my XWindowAttributes $x_window_attrs .= new;
    XGetWindowAttributes($.display, $w, $x_window_attrs);

    # 2. Create frame.
    my Window $frame = XCreateSimpleWindow(
      $.display,
      $.display.DefaultRootWindow,
      $x_window_attrs.x,
      $x_window_attrs.y,
      $x_window_attrs.width,
      $x_window_attrs.height,
      BORDER_WIDTH,
      BORDER_COLOR,
      BG_COLOR
    );

    # 3. Select events on frame.
    XSelectInput($.display, $frame, SubstructureRedirectMask +| SubstructureNotifyMask);

    # 4. Add client to save set, so that it will be restored and kept alive if we crash.
    XAddToSaveSet($.display, $w);
    # 5. Reparent client window.
    XReparentWindow($.display, $w, $frame, 0, 0);
    # 6. Map frame.
    XMapWindow($.display, $frame);
    # 7. Save frame handle.
    %!clients{ $w } = $frame;

    # 8. Grab universal window management actions on client window.
    #   a. Move windows with alt + left button.
    XGrabButton(
        $.display,
        Button1,
        Mod1Mask,
        $w,
        False,
        ButtonPressMask +| ButtonReleaseMask +| ButtonMotionMask,
        GrabModeAsync,
        GrabModeAsync,
        None,
        None) or note "Unable to Grab Window";
    #   b. Resize windows with alt + right button.
    XGrabButton(
        $.display,
        Button3,
        Mod1Mask,
        $w,
        False,
        ButtonPressMask +| ButtonReleaseMask +| ButtonMotionMask,
        GrabModeAsync,
        GrabModeAsync,
        None,
        None);
    #   c. Kill windows with alt + f4.
    XGrabKey(
        $.display,
        XKeysymToKeycode($.display, XK_F4),
        Mod1Mask,
        $w,
        False,
        GrabModeAsync,
        GrabModeAsync);
    #   d. Switch windows with alt + tab.
    XGrabKey(
        $.display,
        XKeysymToKeycode($.display, XK_Tab),
        Mod1Mask,
        $w,
        False,
        GrabModeAsync,
        GrabModeAsync);

    note "Framed window $w [$frame]";
  }

  #| Main event loop.
  method event-loop {
    my XEvent $e .= new;
    note '/* event loop */';
    loop {
      # 1. Get next event.
      XNextEvent($.display, $e);
      note "Received Event: ", $e;

      # 2. Dispatch event.
      given $e.type {
        # when CreateNotify {
        #   OnCreateNotify($e.xcreatewindow);
        # }
        # when DestroyNotify {
        #   OnDestroyNotify($e.xdestroywindow);
        # }
        # when ReparentNotify {
        #   OnReparentNotify($e.xreparent);
        # }
        # when MapNotify {
        #   OnMapNotify($e.xmap);
        # }
        when UnmapNotify {
          # If the window is a client window we manage, unframe it upon UnmapNotify. We
          # need the check because other than a client window, we can receive an
          # UnmapNotify for
          #     - A frame we just destroyed ourselves.
          #     - A pre-existing and mapped top-level window we reparented.
          if ! ( %!clients{ $e.xunmap.window }:exists ) {
            note "Ignore UnmapNotify for non-client window {$e.xunmap.window}";
            note %!clients;
            next;
          }
          if $e.xunmap.event == $.display.DefaultRootWindow {
            note "Ignore UnmapNotify for reparented pre-existing window {$e.xunmap.window}";
            next;
          }
          $.unframe($e.xunmap.window);
        }
        # when ConfigureNotify {
        #   OnConfigureNotify($e.xconfigure);
        # }
        when MapRequest {
          # 1. Frame or re-frame window.
          $.frame($e.xmaprequest.window);
          # 2. Actually map window.
          XMapWindow($.display, $e.xmaprequest.window);
        }
        # when ConfigureRequest {
        #   OnConfigureRequest($e.xconfigurerequest);
        # }
        when ButtonPress {
          # CHECK(clients_.count($e.xbutton.window));
          my $frame = %!clients{ $e.xbutton.window };

          # # 1. Save initial cursor position.
          # drag_start_pos_ = Position<int>($e.xbutton.x_root, $e.xbutton.y_root);
          #
          # # 2. Save initial window info.
          # Window returned_root;
          # int x, y;
          # unsigned width, height, border_width, depth;
          # CHECK(XGetGeometry(
          #     $.display,
          #     frame,
          #     &returned_root,
          #     &x, &y,
          #     &width, &height,
          #     &border_width,
          #     &depth));
          # drag_start_frame_pos_ = Position<int>(x, y);
          # drag_start_frame_size_ = Size<int>(width, height);

          # 3. Raise clicked window to top.
          XRaiseWindow($.display, $frame);
        }
        # when ButtonRelease {
        #   OnButtonRelease($e.xbutton);
        # }
        # when MotionNotify {
        #   # Skip any already pending motion events.
        #   while (XCheckTypedWindowEvent(
        #       $.display, $e.xmotion.window, MotionNotify, $e)) {}
        #   OnMotionNotify($e.xmotion);
        # }
        when KeyPress {
          note "KeyPress Indeed, inspecting "
            ~ sprintf(" state %b & %b, keycode: %x == %x ", $e.xkey.state, Mod1Mask, $e.xkey.keycode,  XKeysymToKeycode($.display, XK_F4));
          if ($e.xkey.state +& Mod1Mask) &&
              ($e.xkey.keycode == XKeysymToKeycode($.display, XK_F4)) {
            note "Closing Window $e.xkey.window";
            # alt + f4: Close window.
            #
            # There are two ways to tell an X window to close. The first is to send it
            # a message of type WM_PROTOCOLS and value WM_DELETE_WINDOW. If the client
            # has not explicitly marked itself as supporting this more civilized
            # behavior (using XSetWMProtocols()), we kill it with XKillClient().
            # Atom* supported_protocols;
            # int num_supported_protocols;
            # if (XGetWMProtocols(display_,
            #                     e.window,
            #                     &supported_protocols,
            #                     &num_supported_protocols) &&
            #     (std::find(supported_protocols,
            #                supported_protocols + num_supported_protocols,
            #                WM_DELETE_WINDOW) !=
            #      supported_protocols + num_supported_protocols)) {
            #   LOG(INFO) << "Gracefully deleting window " << e.window;
            #   # 1. Construct message.
            #   XEvent msg;
            #   memset(&msg, 0, sizeof(msg));
            #   msg.xclient.type = ClientMessage;
            #   msg.xclient.message_type = WM_PROTOCOLS;
            #   msg.xclient.window = e.window;
            #   msg.xclient.format = 32;
            #   msg.xclient.data.l[0] = WM_DELETE_WINDOW;
            #   # 2. Send message to window to be closed.
            #   CHECK(XSendEvent(display_, e.window, false, 0, &msg));
            # } else {
            #   LOG(INFO) << "Killing window " << e.window;
            #   XKillClient(display_, e.window);
            # }
          }
          elsif ($e.xkey.state +& Mod1Mask) &&
                     ($e.xkey.keycode == XKeysymToKeycode($.display, XK_Tab)) {
            note "Alt + tab - switching window";
            # # alt + tab: Switch window.
            # # 1. Find next window.
            # auto i = clients_.find(e.window);
            # CHECK(i != clients_.end());
            # ++i;
            # if (i == clients_.end()) {
            #   i = clients_.begin();
            # }
            # # 2. Raise and set focus.
            # XRaiseWindow(display_, i->second);
            # XSetInputFocus(display_, i->first, RevertToPointerRoot, CurrentTime);
          }
        }
        # when KeyRelease {
        #   OnKeyRelease($e.xkey);
        # }
        default {
          note "Ignored event";
        }
      }
    }
  }

  method unframe($w) {
    # We reverse the steps taken in Frame().
    my $frame = %!clients{ $w };
    if ! $frame {
      note "Request to unframe window that we did not track: $w";
      return;
    }

    # 1. Unmap frame.
    XUnmapWindow($.display, $frame);
    # 2. Reparent client window.
    XReparentWindow( $.display, $w, $.display.DefaultRootWindow, 0, 0);
    # 3. Remove client window from save set, as it is now unrelated to us.
    XRemoveFromSaveSet($.display, $w);
    # 4. Destroy frame.
    XDestroyWindow($.display, $frame);
    # 5. Drop reference to frame handle.
    %!clients{ $w }:delete;

    note "Unframed window $w [ $frame ]";
  }
}
