use v6;

class CSS::Properties::Box {
    use CSS::Properties;
    use CSS::Properties::Units :pt, :ops;
    my Int enum Edges is export(:Edges) <Top Right Bottom Left>;
    has Numeric $.top;
    has Numeric $.right;
    has Numeric $.bottom;
    has Numeric $.left = 0;

    has Array $!padding;
    has Array $!border;
    has Array $!margin;

    use CSS::Properties::Font;
    has CSS::Properties::Font $.font is rw handles <font-size measure units em ex viewport-width viewport-height>;
    has CSS::Properties $.css;

    has Hash @.save;

    my subset BoundingBox of Str where 'content'|'border'|'margin'|'padding';

    submethod TWEAK(
        Numeric :$width = 595pt,
        Numeric :$height = 842pt,
        Numeric :$!top = $height,
        Numeric :$!bottom = $!top - $height,
        Numeric :$!right = $!left + $width,
        Str :$style = '',
        Numeric :$em = 12pt,
        Numeric :$ex = 0.75 * $em,
        :font($),
        |c
    ) {
        $!css //= CSS::Properties.new(:$style, |c),
        $!font //= CSS::Properties::Font.new: :$em, :$ex, :$!css;
        self!resize;
    }

    method !resize {
        die "left > right" if $!left > $!right;
        die "bottom > top" if $!bottom > $!top;
        $!padding = Nil;
        $!border = Nil;
        $!margin = Nil;
    }

    multi method top is rw {
        Proxy.new(
            FETCH => sub ($) { $!top },
            STORE => sub ($, $!top) { self!resize },
            );
    }

    multi method top(BoundingBox $box) is rw {
        self."$box"()[Top];
    }

    multi method right is rw { $!right }
    multi method right(BoundingBox $box) is rw {
        self."$box"()[Right];
    }

    multi method bottom is rw { $!bottom }
    multi method bottom(BoundingBox $box) is rw {
        self."$box"()[Bottom]
    }

    multi method left is rw { $!left }
    multi method left(BoundingBox $box) is rw {
        self."$box"()[Left]
    }

    multi method width { $!right - $!left }
    multi method width(BoundingBox $box) {
        my \box = self."$box"();
        box[Right] - box[Left]
    }

    multi method height { $!top - $!bottom }
    multi method height(BoundingBox $box) {
        my \box = self."$box"();
        box[Top] - box[Bottom]
    }

    method !width($qty is copy) {
        $qty = $_ with { :thin(1pt), :medium(2pt), :thick(3pt) }{$qty};
        self.measure($qty);
    }

    method measurements(List $qtys) {
        [ $qtys.map: { self!width($_) } ]
    }

    method padding returns Array {
        $!padding //= self!enclose($.Array, self.measurements($!css.padding));
    }
    method border returns Array {
        $!border //= self!enclose($.padding, self.measurements($!css.border-width));
    }
    method margin returns Array {
        $!margin //= self!enclose($.border, self.measurements($!css.margin));
    }

    method content returns Array is rw { self.Array }

    method !enclose(List $inner, List $outer) {
        [
         $inner[Top]    + $outer[Top],
         $inner[Right]  + $outer[Right],
         $inner[Bottom] - $outer[Bottom],
         $inner[Left]   - $outer[Left],
        ]
    }

    method css-height($css = $!css) {
        my Numeric $height = $_ with $.measure($css.height);
        with $.measure($css.max-height) {
            $height = $_
                if $height.defined && $height > $_;
        }
        with $.measure($css.min-height) {
            $height = $_
                if $height.defined && $height < $_;
        }
        $height;
    }

    method css-width($css = $!css) {
        my Numeric $width = $_ with $.measure($css.width);
        with $.measure($css.max-width) {
            $width = $_
                if !$width.defined || $width > $_;
        }
        with $.measure($css.min-width) {
            $width = $_
                if $width.defined && $width < $_;
        }
        $width;
    }

    method Array is rw {
        Proxy.new(
            FETCH => sub ($) {
                [$!top, $!right, $!bottom, $!left]
            },
            STORE => sub ($,@v) {
                my $width  = $!right - $!left;
                my $height = $!top - $!bottom;
                $!top    = $_ with @v[Top];
                $!right  = $_ with @v[Right];
                $!bottom = @v[Bottom] // $!top - $height;
                $!left   = @v[Left] // $!right - $width;
                self!resize;
            });
    }

    method move( \x, \y) {
        self.Array = [y, x ];
    }

    method translate( \x, \y) {
        self.Array = [ $!top + y, $!right + x ];
    }

    method save {
        @!save.push: {
            :$!font,
        }
        $!font = $!font.clone;
    }

    method restore {
        if @!save {
            with @!save.pop {
                $!font     = .<font>;
            }
        }
    }

    method can(Str \name) {
       my @meth = callsame;
       unless @meth {
           given name {
               when /^ (padding|border|margin)'-'(top|right|bottom|left) $/ {
                   #| absolute positions
                   my Str $box = ~$0;
                   my UInt \edge = %( :top(Top), :right(Right), :bottom(Bottom), :left(Left) ){$1};
                   @meth.push: method { self."$box"()[edge] };
               }
               when /^ (padding|border|margin)'-'(width|height) $/ {
                   #| cumulative widths and heights
                   my Str $box = ~$0;
                   @meth.push: do given ~$1 {
                       when 'width'  { method { .[Right] - .[Left] with self."$box"() } }
                       when 'height' { method { .[Top] - .[Bottom] with self."$box"() } }
                   }
               }
           }
           self.^add_method(name, $_) with @meth[0];
       }
       @meth;
    }
    method dispatch:<.?>(\name, |c) is raw {
        self.can(name) ?? self."{name}"(|c) !! Nil
    }
    method FALLBACK(Str \name, |c) {
        self.can(name)
            ?? self."{name}"(|c)
            !! die die X::Method::NotFound.new( :method(name), :typename(self.^name) );
    }
}
