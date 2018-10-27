use v6;
use Threads;

my $size = +(@*ARGS[0] // 321);
my $max_iterations = 50;

my $upper-right = -2 + (5/4)i;
my $lower-left = 1/2 - (5/4)i;

say "Mouse left button: click and drag to define a zoom area";
say "Mouse right button: click to create a Julia set for that point";
say "Press 'm' to increase the number of iterations for a window";
say "Press 's' to save the current window to a file";
say "";

my @color_map = (
    "0 0 0",
    "0 0 252",
    "64 0 252",
    "124 0 252",
    "188 0 252",
    "252 0 252",
    "252 0 188",
    "252 0 124",
    "252 0 64",
    "252 0 0",
    "252 64 0",
    "252 124 0",
    "252 188 0",
    "252 252 0",
    "188 252 0",
    "124 252 0",
    "64 252 0",
    "0 252 0",
    "0 252 64",
    "0 252 124",
    "0 252 188",
    "0 252 252",
    "0 188 252",
    "0 124 252",
    "0 64 252",
    "124 124 252",
    "156 124 252",
    "188 124 252",
    "220 124 252",
    "252 124 252",
    "252 124 220",
    "252 124 188",
    "252 124 156",
    "252 124 124",
    "252 156 124",
    "252 188 124",
    "252 220 124",
    "252 252 124",
    "220 252 124",
    "188 252 124",
    "156 252 124",
    "124 252 124",
    "124 252 156",
    "124 252 188",
    "124 252 220",
    "124 252 252",
    "124 220 252",
    "124 188 252",
    "124 156 252",
    "180 180 252",
    "196 180 252",
    "216 180 252",
    "232 180 252",
    "252 180 252",
    "252 180 232",
    "252 180 216",
    "252 180 196",
    "252 180 180",
    "252 196 180",
    "252 216 180",
    "252 232 180",
    "252 252 180",
    "232 252 180",
    "216 252 180",
    "196 252 180",
    "180 252 180",
    "180 252 196",
    "180 252 216",
    "180 252 232",
    "180 252 252",
    "180 232 252",
    "180 216 252",
    "180 196 252",
);

constant $GTK  = "gtk-sharp, Version=2.12.0.0, Culture=neutral, PublicKeyToken=35e10195dab3c99f";
constant $GDK  = "gdk-sharp, Version=2.12.0.0, Culture=neutral, PublicKeyToken=35e10195dab3c99f";

constant Application    = CLR::("Gtk.Application,$GTK");
constant Window         = CLR::("Gtk.Window,$GTK");
constant GdkCairoHelper = CLR::("Gdk.CairoHelper,$GDK");
constant GdkGC          = CLR::("Gdk.GC,$GDK");
constant GdkRgb         = CLR::("Gdk.Rgb,$GDK");
constant GdkRgbDither   = CLR::("Gdk.RgbDither,$GDK");
constant GdkColor       = CLR::("Gdk.Color,$GDK");
constant GtkDrawingArea = CLR::("Gtk.DrawingArea,$GTK");
constant GtkEventBox    = CLR::("Gtk.EventBox,$GTK");
constant SystemByte     = CLR::("System.Byte");
constant SystemIntPtr   = CLR::("System.IntPtr");
constant ByteArray      = CLR::("System.Byte[]");

my @red =   @color_map.map({ SystemByte.Parse($_.comb(/\d+/)[0]) });
my @green = @color_map.map({ SystemByte.Parse($_.comb(/\d+/)[1]) });
my @blue =  @color_map.map({ SystemByte.Parse($_.comb(/\d+/)[2]) });

my @windows;

class WorkQueue {
    my $monitor = Monitor.new; # NIECZA no class attributes
    method monitor() { $monitor }
    my @queue;

    method new() { self }

    method push($item) {
        $monitor.lock({
            push @queue, $item;
            $monitor.pulse;
        });
    }

    method shift() {
        $monitor.lock({
            unless @queue {
                say "Waiting for work at {times[0]}";
                $monitor.wait until @queue;
                say "Got work at {times[0]}";
            }
            shift @queue;
        })
    }

    method run() {
        loop {
            my $item = self.shift;
            next if $item.cancelled;
            $item.run.();
            $item.mark-done;
        }
    }
}

for ^(%*ENV<THREADS> // CLR::System::Environment.ProcessorCount) {
    Thread.new({ WorkQueue.run });
}

class WorkItem {
    has Bool $!done = False;
    has Bool $!cancelled = False;

    has Callable &.run;
    has Callable &.done-cb;

    method is-done() { WorkQueue.monitor.lock({ $!done }) }
    method mark-done() {
        &.done-cb.() unless WorkQueue.monitor.lock({ $!done++ })
    }

    method cancelled() { WorkQueue.monitor.lock({ $!cancelled }) }
    method cancel() { WorkQueue.monitor.lock({ $!cancelled = True }) }
}

class FractalSet {
    has Bool $.is-julia;
    has Complex $.upper-right;
    has Real $.delta;
    has Int $.width;
    has Int $.height;
    has Int $.max_iterations;
    has Complex $.c;
    has @.rows;
    has @.line-work-items;
    has $.new-upper-right;

    has $.draw-area;

    method stop-work() {
        for @.line-work-items { .cancel }
        @.line-work-items = ();
    }

    method start-work() {
        self.stop-work if @.line-work-items;

        say "Upper: " ~ $.upper-right;
        say "Delta: " ~ $.delta;

        # make local copies of everything we need to avoid data races
        my $julia-z0 = $.c;
        my $is-julia = $.is-julia;
        my $ur = $.upper-right;
        my $width = $.width;
        my $delta = $.delta;
        my $max_iterations = $.max_iterations;
        
        sub julia(Complex $c, Complex $z0) {
            my $z = $z0;
            my $i;
            loop ($i = 0; $i < $max_iterations; $i++) {
                if $z.abs > 2 {
                    return $i + 1;
                }
                $z = $z * $z + $c;
            }
            return 0;
        }
        
        my @rows = @.rows = ByteArray.new($width * 3) xx $.height;

        my $y_;
        loop ($y_ = 0; $y_ < $.height; $y_++) {
            my $y = $y_;

            sub row() {
                my $row = @rows[$y];
                my $counter = 0;
                my $counter_end = $counter + 3 * $width;
                my $c = $ur - $y * $delta * i;

                while $counter < $counter_end {
                    my $value = $is-julia ?? julia($julia-z0, $c) !! julia($c, 0i);
                    $row.Set($counter++, @red[$value % 72]);
                    $row.Set($counter++, @green[$value % 72]);
                    $row.Set($counter++, @blue[$value % 72]);
                    $c += $delta;
                }
            }

            sub done() {
                Application.Invoke(-> $ , $ {
                    $.draw-area.QueueDrawArea(0, $y, $width, 1);
                });
            }

            my $wi = WorkItem.new(run => &row, done-cb => &done);
            WorkQueue.push($wi);
            push @.line-work-items, $wi;
        }
    }

    method resize($width, $height) {
        self.stop-work;
        $.delta *= $.height / $height;
        $.width = $width;
        $.height = $height;
        self.start-work;
    }
    
    method increase-max-iterations() {
        self.stop-work;
        $.max_iterations += 32;
        self.start-work;
    }

    method xy-to-c($x, $y) {
        $.upper-right + $x * $.delta - $y * $.delta * i;
    }

    method remember-new-upper-right($x, $y) {
        $.new-upper-right = self.xy-to-c($x, $y);
    }

    method forget-new-upper-right() {
        $.new-upper-right = Complex;
    }

    method build-window()
    {
        my $index = +@windows;
        @windows.push(self);
        self.start-work;

        my $window = Window.new($.is-julia ?? "julia $index" !! "mandelbrot $index");
        $window.SetData("Id", SystemIntPtr.new($index));
        $window.Resize($.width, $.height);  # TODO: resize at runtime NYI

        my $event-box = GtkEventBox.new;
        $event-box.SetData("Id", SystemIntPtr.new($index));
        $event-box.add_ButtonPressEvent(&ButtonPressEvent);
        $event-box.add_ButtonReleaseEvent(&ButtonReleaseEvent);

        my $drawingarea = $.draw-area = GtkDrawingArea.new;
        $drawingarea.SetData("Id", SystemIntPtr.new($index));
        $drawingarea.add_ExposeEvent(&ExposeEvent);
        $window.add_DeleteEvent(&DeleteEvent);
        $event-box.Add($drawingarea);

        $window.Add($event-box);
        $window.add_KeyReleaseEvent(&KeyReleaseEvent);
        $window.ShowAll;
    }

    my $file-count = 0;

    method write-file() {
        my $filename = $.is-julia ?? "julia-{ $file-count++ }.ppm" !! "mandelbrot-{ $file-count++ }.ppm";
        say "Starting to write $filename";
        
        my $file = open $filename, :w;
        $file.say: "P3";
        $file.say: "# $filename";
        $file.say: "# $.upper-right $.delta $.max_iterations";
        $file.say: "$.width $.height";
        $file.say: "255";
        for @.rows -> $row {
            for ^$row.Length -> $i {
                $file.print: $row.GetValue($i).ToString ~ " ";
                $file.say: "" if $i % 4 == 3;
            }
            $file.say: "";
        }
        $file.close;
        say "$filename written";
    }
}

Application.Init;
GdkRgb.Init;

FractalSet.new(is-julia => False,
               upper-right => $upper-right, 
               delta => ($lower-left.re - $upper-right.re) / $size,
               width => $size, 
               height => $size,
               max_iterations => $max_iterations).build-window;

Application.Run;  # end of main program, it's all over when this returns

sub ButtonPressEvent($obj, $args) {  #OK not used
    my $index = $obj.GetData("Id").ToInt32();
    my $set = @windows[$index];
    
    given $args.Event.Button {
        when 1 {
            $set.remember-new-upper-right($args.Event.X, $args.Event.Y);
        }
    }
}

sub ButtonReleaseEvent($obj, $args) {  #OK not used
    my $index = $obj.GetData("Id").ToInt32();
    my $set = @windows[$index];
    
    given $args.Event.Button {
        when 1 {
            if $set.new-upper-right {
                my $c1 = $set.new-upper-right;
                my $c2 = $set.xy-to-c($args.Event.X, $args.Event.Y);
                my $upper-right = ($c1.re min $c2.re) + ($c1.im max $c2.im)i;
                my $lower-left = ($c1.re max $c2.re) + ($c1.im min $c2.im)i;
                my $height-ratio = ($upper-right.im - $lower-left.im) / ($lower-left.re - $upper-right.re);
                if 0 < $height-ratio < 100 {
                    FractalSet.new(is-julia => False,
                                   upper-right => $upper-right, 
                                   delta => ($lower-left.re - $upper-right.re) / $size,
                                   width => ($size / $height-ratio).Int, 
                                   height => $size,
                                   max_iterations => $set.max_iterations).build-window;
                }
            }
        }
        when 3 {
            FractalSet.new(is-julia => True,
                          upper-right => -5/4 + (5/4)i,
                          delta => (5 / 2) / $size,
                          width => $size, 
                          height => $size,
                          max_iterations => $max_iterations,
                          c => $set.xy-to-c($args.Event.X, $args.Event.Y)).build-window;
        }
    }
    
    $set.forget-new-upper-right;
}

sub KeyReleaseEvent($obj, $args) {
    my $index = $obj.GetData("Id").ToInt32();
    my $set = @windows[$index];
    
    given $args.Event.Key {
        when 'm' | 'M' {
            $set.increase-max-iterations;
        }
        when 's' | 'S' {
            $set.write-file;
        }
    }
}

sub DeleteEvent($obj, $args) {  #OK not used
    Application.Quit;
};

sub ExposeEvent($obj, $args)
{
    my $index = $obj.GetData("Id").ToInt32();
    my $set = @windows[$index];

    my $window = $obj.GdkWindow;
    my $windowX=0; my $windowY=0; my $windowWidth=0; my $windowHeight=0; my $windowDepth=0;
    $window.GetGeometry($windowX, $windowY, $windowWidth, $windowHeight, $windowDepth);
    if $windowHeight != $set.height || $windowWidth != $set.width {
        $set.resize($windowWidth, $windowHeight);
    }

    my $gc = GdkGC.new($window);
    my $y0 = $args.Event.Area.Y - $windowY;
    for $y0..^($y0+$args.Event.Area.Height) -> $y {
        if $y < $set.line-work-items && $set.line-work-items[$y].is-done {
            $window.DrawRgbImage($gc, $windowX, $windowY+$y, $windowWidth, 1,
                GdkRgbDither.Normal, $set.rows[$y], $windowWidth * 3);
        }
        else {
            $window.DrawRectangle($gc, True, $windowX, $windowY+$y,
                $windowWidth, 1);
        }
    }
};

