use NativeCall;
use nqp;
unit module Informative;
=comment
    The clever code is copied from GTK::Simple
    The Windows code in particular comes from GTK::Simple.
    
=comment code for the inform dialog box 

    class Informing {
        has $!app;
        has Bool $!reinit = True;
        has $!inf-lable;
        has $!box;
        has $!btn-box;
        has $!deleted_supply;
        has $!title;
        has $!position;
        has $!timer-lable;
        has @!buttons;
        has @!entries;
        has %.data = {};
        has $.response;
        has Supply $!sup = self.g-timeout(1000);
        has Tap $!tap;
        has Int $!timer = 10;
        has Bool $!show-countdown = True;
        has Str $.text is rw = "Say <span color=\"green\">something</span><span weight=\"bold\" color=\"red\"> beautiful</span>";

        enum GtkWindowPosition (
            GTK_WIN_POS_NONE               => 0,
            GTK_WIN_POS_CENTER             => 1,
            GTK_WIN_POS_MOUSE              => 2,
            GTK_WIN_POS_CENTER_ALWAYS      => 3,
            GTK_WIN_POS_CENTER_ON_PARENT   => 4,
        );

        class GtkWidget is repr('CPointer') { }

        submethod BUILD (
        Str :$!title = "Inform",
        :@buttons = (),
        :@entries = (),
        GtkWindowPosition :$!position = GTK_WIN_POS_CENTER
        ) {
            my $arg_arr = CArray[Str].new;
            $arg_arr[0] = $*PROGRAM.Str;
            my $argc = CArray[int32].new;
            $argc[0] = 1;
            my $argv = CArray[CArray[Str]].new;
            $argv[0] = $arg_arr;
            for @buttons -> $el { 
                @!buttons.push: { :name($el.key), :lable($el.value) }
            };
            for @entries -> $el {
                @!entries.push: { :name($el.key), :lable($el.value) }
            };
            
            gtk_init($argc, $argv);
            
            self.init;
        }
            
        submethod init {
            $!app = gtk_window_new(0);
            gtk_window_set_title($!app, $!title.Str);

            g_signal_connect_wd($!app, "delete-event",
            -> $, $ {
                self.destroy
            }, OpaquePointer, 0);

            # Set window default size and position
            gtk_window_set_default_size($!app, 100, 40);
            gtk_window_set_position($!app, $!position);
            gtk_container_set_border_width($!app, 10);
            $!box = gtk_box_new( 1 , 0 ); # vertical, no border
            $!btn-box = gtk_box_new( 0 , 0); # horizontal
            $!inf-lable = gtk_label_new(''.Str);
            $!timer-lable = gtk_label_new(''.Str);
            gtk_container_add( $!app, $!box );
            gtk_box_pack_start( $!box, $!inf-lable, 0,0,0);
            gtk_box_pack_end( $!box, $!btn-box, 0,0,0);
            if @!entries.elems {
                # Design decision is not to allow entries without buttons
                @!buttons = ( { :name('OK'), :lable('OK') }, {:name("Cancel"),:lable('Cancel')}) 
                    unless @!buttons.elems;
                for @!entries -> %en {
                    %en<widget> = gtk_entry_new( );
                    # treat passwords differently
                    gtk_entry_set_visibility(%en<widget>, False)
                        if %en<name> ~~ /['-'|_]pw$/ ;
                    my $ebox = gtk_box_new( 0,0);
                    gtk_box_pack_start( $ebox, gtk_label_new( %en<lable>.Str ), 0,0,0);
                    gtk_box_pack_start( $ebox, %en<widget>, 0,0,0);
                    gtk_box_pack_start( $!box, $ebox, -1,-1,1);
                }
            }
            if @!buttons.elems {
                for @!buttons -> %b {
                    %b<widget> = gtk_button_new_with_label( %b<lable>.Str );
                    gtk_box_pack_start( $!btn-box, %b<widget>, -1,-1,1);
                    g_signal_connect_wd( %b<widget>, 'clicked', 
                        -> $widget, $event { 
                            $!response =  %b<name>;
                            # if there are entries then transfer the text information
                            # let user decide what to do with info
                            if @!entries.elems {
                                for @!entries -> %en {
                                    %!data{ %en<name> } = gtk_entry_get_text( %en<widget> );
                                }
                            }
                            gtk_widget_hide($!app );
                            gtk_main_quit
                        },
                        OpaquePointer, 0);
                }
            } else {
                gtk_box_pack_end( $!btn-box, $!timer-lable, 0,0,0);
            }
            $!reinit = False;
        }
        
        method make-text( $count ) {
            my $lable;
            if $!show-countdown and $!timer > 0 {
                $lable = "<span weight=\"bold\" size=\"x-large\" color=\"white\">$count sec</span>"
            } elsif $!show-countdown {
                $lable = "<span weight=\"bold\" size=\"x-large\" color=\"white\">Til window is closed</span>"
            }
            with $lable {
                gtk_label_set_markup($!timer-lable, $lable.Str)
            } else {
                gtk_label_set_markup($!timer-lable, "".Str)                
            }
        }

        method hide() {
            $!tap.close;
            gtk_widget_hide($!app);
            gtk_main_quit();
        }

        method show(
            Str $str?,
            Int :$timer,
            Bool :$show-countdown
        ) {
            self.init if $!reinit;
            $!text = $str
                with $str;
            gtk_label_set_markup($!inf-lable, $!text.Str);
            
            unless @!buttons.elems {
                $!timer = $timer // $!timer;
                $!show-countdown = $show-countdown // $!show-countdown;
                $!text = $str // $!text;
                self.make-text( $!timer );
                
                if $!timer > 0 {
                    my $counter = $!timer - 1;
                    $!tap = $!sup.tap( { 
                        self.make-text( $counter );
                        if ($counter <= 0) {
                            self.hide();
                        }
                        $counter--;
                        } );
                    self.deleted.tap( { self.hide; });
                }
            }
                        
            gtk_widget_show_all($!app);
            gtk_main();
        }

        method g-timeout(Cool $usecs) {
            my $s = Supplier.new;
            my $starttime = nqp::time_n();
            my $lasttime  = nqp::time_n();
            g_timeout_add($usecs.Int,
                sub (*@) {
                    my $dt = nqp::time_n() - $lasttime;
                    $lasttime = nqp::time_n();
                    $s.emit((nqp::time_n() - $starttime, $dt));
                    return 1;
                }, OpaquePointer);
            return $s.Supply;
        }

        method destroy() {
            $!tap.close with $!tap;
            $!reinit = True;
            $!response = '_Destroyed';
            gtk_widget_destroy($!app);
            gtk_main_quit();
        }

        method deleted() {
            $!deleted_supply //= do {
                my $s = Supplier.new;
                g_signal_connect_wd($!app, "delete-event",
                    -> $, $ {
                        $s.emit(self);
                        CATCH { default { note $_; } }
                    },
                    OpaquePointer, 0);
                $s.Supply;
            }
        }
        
        =comment
            Subroutines only needed to work with Windows
            copied directly from GTK::Simple::NativeLib            
                    
        # On any non-windows machine, this just returns the library name
        # for the native calls.
        #
        # However, on a windows machine, we search @*INC to see if our bundled
        # copy of the GTK .dll files are installed. Since they will then no longer
        # be in the system $PATH, we need to load each .dll file individually, in
        # dependency order. Thus explaining all the 'try load-*' calls below.
        #
        # Each load-* function just attempts to call a non-existing symbol in the
        # .dll we are trying to load. This call will fail, but it has the side effect
        # of loading the .dll file, which is all we need.

        sub gtk-lib is export {
            state $lib;
            unless $lib {
                if $*VM.config<dll> ~~ /dll/ {
                    try load-gdk-lib;
                    try load-atk-lib;
                    try load-cairo-gobject-lib;
                    try load-cairo-lib;
                    try load-gdk-pixbuf-lib;
                    try load-gio-lib;
                    try load-glib-lib;
                    try load-gmodule-lib;
                    try load-gobject-lib;
                    try load-intl-lib;
                    try load-pango-lib;
                    try load-pangocairo-lib;
                    try load-pangowin32-lib;
                    $lib = find-bundled('libgtk-3-0.dll');
                } else {
                    $lib = $*VM.platform-library-name('gtk-3'.IO).Str;
                }
            }
            $lib
        }

        sub gdk-lib is export {
            state $lib;
            unless $lib {
                if $*VM.config<dll> ~~ /dll/ {
                    try load-cairo-gobject-lib;
                    try load-cairo-lib;
                    try load-gdk-pixbuf-lib;
                    try load-gio-lib;
                    try load-glib-lib;
                    try load-gobject-lib;
                    try load-intl-lib;
                    try load-pango-lib;
                    try load-pangocairo-lib;
                    $lib = find-bundled('libgdk-3-0.dll');
                } else {
                    $lib = $*VM.platform-library-name('gdk-3'.IO).Str;
                }
            }
            $lib
        }

        sub glib-lib is export {
            state $lib;
            unless $lib {
                if $*VM.config<dll> ~~ /dll/ {
                    try load-intl-lib;
                    $lib = find-bundled('libglib-2.0-0.dll');
                } else {
                    $lib = $*VM.platform-library-name('glib-2.0'.IO).Str;
                }
            }
            $lib
        }

        sub gobject-lib is export {
            state $lib;
            unless $lib {
                if $*VM.config<dll> ~~ /dll/ {
                    try load-glib-lib;
                    try load-ffi-lib;
                    $lib = find-bundled('libgobject-2.0-0.dll');
                } else {
                    $lib = $*VM.platform-library-name('gobject-2.0'.IO).Str;
                }
            }
            $lib
        }

        sub find-bundled($lib is copy) {
            # if we can't find one, assume there's a system install
            my $base = "blib/lib/GTK/$lib";

            if my $file = %?RESOURCES{$base} {
                    $file.IO.copy($*SPEC.tmpdir ~ '\\' ~ $lib);
                    $lib = $*SPEC.tmpdir ~ '\\' ~ $lib;
            }

            $lib;
        }

        # windows DLL dependency stuff ...

        sub atk-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('libatk-1.0-0.dll');
            }
            $lib
        }
        sub cairo-gobject-lib {
            state $lib;
            unless $lib {
                try load-cairo-lib;
                try load-glib-lib;
                try load-gobject-lib;
                $lib = find-bundled('libcairo-gobject-2.dll');
            }
            $lib
        }
        sub cairo-lib {
            state $lib;
            unless $lib {
                try load-fontconfig-lib;
                try load-freetype-lib;
                try load-pixman-lib;
                try load-png-lib;
                try load-zlib-lib;
                $lib = find-bundled('libcairo-2.dll');
            }
            $lib
        }
        sub gdk-pixbuf-lib {
            state $lib;
            unless $lib {
                try load-gio-lib;
                try load-glib-lib;
                try load-gmodule-lib;
                try load-gobject-lib;
                try load-intl-lib;
                try load-png-lib;
                $lib = find-bundled('libgdk_pixbuf-2.0-0.dll');
            }
            $lib
        }
        sub gio-lib {
            state $lib;
            unless $lib {
                try load-glib-lib;
                try load-gmodule-lib;
                try load-gobject-lib;
                try load-intl-lib;
                try load-zlib-lib;
                $lib = find-bundled('libgio-2.0-0.dll');
            }
            $lib
        }
        sub gmodule-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('libgmodule-2.0-0.dll');
            }
            $lib
        }
        sub intl-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('libintl-8.dll');
            }
            $lib
        }
        sub pango-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('libpango-1.0-0.dll');
            }
            $lib
        }
        sub pangocairo-lib {
            state $lib;
            unless $lib {
                try load-pango-lib;
                try load-pangoft2-lib;
                try load-pangowin32-lib;
                try load-cairo-lib;
                try load-fontconfig-lib;
                try load-freetype-lib;
                try load-glib-lib;
                try load-gobject-lib;
                $lib = find-bundled('libpangocairo-1.0-0.dll');
            }
            $lib
        }
        sub pangowin32-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('libpangowin32-1.0-0.dll');
            }
            $lib
        }
        sub fontconfig-lib {
            state $lib;
            unless $lib {
                try load-freetype-lib;
                try load-xml-lib;
                $lib = find-bundled('libfontconfig-1.dll');
            }
            $lib
        }
        sub freetype-lib {
            state $lib;
            unless $lib {
                try load-zlib-lib;
                $lib = find-bundled('libfreetype-6.dll');
            }
            $lib
        }
        sub pixman-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('libpixman-1-0.dll');
            }
            $lib
        }
        sub png-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('libpng15-15.dll');
            }
            $lib
        }
        sub zlib-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('zlib1.dll');
            }
            $lib
        }
        sub xml-lib {
            state $lib;
            unless $lib {
                try load-iconv-lib;
                try load-lzma-lib;
                $lib = find-bundled('libxml2-2.dll');
            }
            $lib
        }
        sub iconv-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('libiconv-2.dll');
            }
            $lib
        }
        sub lzma-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('liblzma-5.dll');
            }
            $lib
        }
        sub ffi-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('libffi-6.dll');
            }
            $lib
        }
        sub pangoft2-lib {
            state $lib;
            unless $lib {
                $lib = find-bundled('libpangoft2-1.0-0.dll');
            }
            $lib
        }

        sub load-gdk-lib is native(&gdk-lib) { ... }
        sub load-atk-lib is native(&atk-lib) { ... }
        sub load-cairo-gobject-lib is native(&cairo-gobject-lib) { ... }
        sub load-cairo-lib is native(&cairo-lib) { ... }
        sub load-gdk-pixbuf-lib is native(&gdk-pixbuf-lib) { ... }
        sub load-gio-lib is native(&gio-lib) { ... }
        sub load-glib-lib is native(&glib-lib) { ... }
        sub load-gmodule-lib is native(&gmodule-lib) { ... }
        sub load-gobject-lib is native(&gobject-lib) { ... }
        sub load-intl-lib is native(&intl-lib) { ... }
        sub load-pango-lib is native(&pango-lib) { ... }
        sub load-pangocairo-lib is native(&pangocairo-lib) { ... }
        sub load-pangowin32-lib is native(&pangowin32-lib) { ... }
        sub load-fontconfig-lib is native(&fontconfig-lib) { ... }
        sub load-freetype-lib is native(&freetype-lib) { ... }
        sub load-pixman-lib is native(&pixman-lib) { ... }
        sub load-png-lib is native(&png-lib) { ... }
        sub load-zlib-lib is native(&zlib-lib) { ... }
        sub load-xml-lib is native(&xml-lib) { ... }
        sub load-iconv-lib is native(&iconv-lib) { ... }
        sub load-lzma-lib is native(&lzma-lib) { ... }
        sub load-ffi-lib is native(&ffi-lib) { ... }
        sub load-pangoft2-lib is native(&pangoft2-lib) { ... }
        
        =comment
            The actual gtk native subroutines needed by the Informing class
            
        sub gtk_init(CArray[int32] $argc, CArray[CArray[Str]] $argv)
            is native(&gtk-lib)
            {*}

        sub gtk_widget_show(GtkWidget $widgetw)
            is native(&gtk-lib)
            is export
            {*}

        sub gtk_widget_hide(GtkWidget $widgetw)
            is native(&gtk-lib)
            is export    
            { * }

        sub gtk_main()
            is native(&gtk-lib)
            {*}

        sub gtk_main_quit()
            is native(&gtk-lib)
            {*}

        sub gtk_window_new(int32 $window_type)
            is native(&gtk-lib)
            returns GtkWidget
            {*}

        sub gtk_window_set_title(GtkWidget $w, Str $title)
            is native(&gtk-lib)
            returns GtkWidget
            {*}

        sub gtk_window_set_position(GtkWidget $window, int32 $position)
            is native(&gtk-lib)
            { * }

        sub gtk_window_set_default_size(GtkWidget $window, int32 $width, int32 $height)
            is native(&gtk-lib)
            { * }

        sub g_signal_connect_wd(GtkWidget $widget, Str $signal,
            &Handler (GtkWidget $h_widget, OpaquePointer $h_data),
            OpaquePointer $data, int32 $connect_flags)
            returns int32
            is native(&gobject-lib)
            is symbol('g_signal_connect_object')
            { * }

        sub g_timeout_add(int32 $interval, &Handler (OpaquePointer $h_data, --> int32), OpaquePointer $data)
            is native(&gtk-lib)
            returns int32
            {*}

        sub gtk_widget_destroy(GtkWidget $widget)
            is native(&gtk-lib)
            {*}

        sub gtk_container_add(GtkWidget $container, GtkWidget $widgen)
            is native(&gtk-lib)
            {*}

        sub gtk_container_set_border_width(GtkWidget $container, int32 $border_width)
            is native(&gtk-lib)
            is export
            {*}
            
        sub gtk_widget_show_all(GtkWidget $widgetw)
            is native(&gtk-lib)
            {*}
                
        sub gtk_label_new(Str $text)
            is native(&gtk-lib)
            returns GtkWidget
            {*}

        sub gtk_label_set_markup(GtkWidget $label, Str $text)
            is native(&gtk-lib)
            {*}
            
        sub gtk_box_new(int32, int32)
            is native(&gtk-lib)
            returns GtkWidget
            {*}
                    
        sub gtk_button_new_with_label(Str $label)
            is native(&gtk-lib)
            returns GtkWidget
            {*}
            
        sub gtk_box_pack_start(GtkWidget, GtkWidget, int32, int32, int32)
            is native(&gtk-lib)
            {*}
            
        sub gtk_box_pack_end(GtkWidget, GtkWidget, int32, int32, int32)
            is native(&gtk-lib)
            {*}
                    
        sub gtk_entry_new()
            is native(&gtk-lib)
            returns GtkWidget
            {*}

        sub gtk_entry_get_text(GtkWidget $entry)
            is native(&gtk-lib)
            returns Str
            {*}
            
        sub gtk_entry_set_visibility (GtkWidget $entry, Bool $visible)
            is native(&gtk-lib)
            {*}
            

    } # end of Informing class

    sub inform(
        Str $message?, 
        Int :$timer, 
        Str :$title = 'Inform', 
        Bool :$show-countdown,  
        :@buttons,
        :@entries
        ) is export {
        my Informing $pop .=new( :title( $title ), :buttons(@buttons), :entries(@entries) );
        $pop.show( $message, :timer( $timer ), :show-countdown($show-countdown) );
        return $pop
    }
