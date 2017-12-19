use v6;
class HTML::Canvas::To::Cairo {

    use Cairo;
    use Color;
    use CSS::Declarations::Font;
    use HTML::Canvas;
    use HTML::Canvas::Gradient;
    use HTML::Canvas::Image;
    use HTML::Canvas::ImageData;
    use HTML::Canvas::Pattern;
    has HTML::Canvas $.canvas is rw .= new;
    has Cairo::Surface $.surface handles <width height>;
    has Cairo::Context $.ctx;
    class FontCache
        is CSS::Declarations::Font {

        use Font::FreeType;
        use Font::FreeType::Native;

        has Font::FreeType $!freetype .= new;
        has FT_Face $.font-obj;

        method font-obj {
            state %cache;
            my Str $file = $.find-font;
            %cache{$file} //= do {
                my Font::FreeType::Face $face = $!freetype.face($file);
                my FT_Face $ft-face = $face.struct;
                $ft-face.FT_Reference_Face;
                Cairo::Font.create($ft-face, :free-type);
            };
        }
    }
    has FontCache $!font .= new;

    submethod TWEAK(Numeric :$width = $!canvas.width, Numeric :$height = $!canvas.height) {
        $!surface //= Cairo::Image.create(Cairo::FORMAT_ARGB32, $width // 128, $height // 128);
        $!ctx //= Cairo::Context.new($!surface);
        with $!canvas {
            .callback.push: self.callback
        }
    }

    method render(HTML::Canvas $canvas --> Cairo::Surface) {
        my $width = $canvas.width // 128;
        my $height = $canvas.height // 128;
        my $obj = self.new: :$width, :$height;
        $canvas.render($obj);
        $obj.surface;
    }

    method callback {
        sub (Str $op, |c) {
            if self.can: $op {
                self."{$op}"(|c);
            }
            else {
                warn "Canvas call not supported in Cairo: $op"
            }
        }
    }

    method _start {
	my $scale = 1.0 / $!canvas.adjusted-font-size(1.0);
	self.font;
	self.lineWidth($!canvas.lineWidth);
    }
    method _finish {
    }

    method save {
        $!ctx.save;
    }
    method restore {
        $!ctx.restore;
        $!font.css = $!canvas.css;
    }
    has %!pattern-cache{Any};
    method !make-pattern(HTML::Canvas::Pattern $pattern) {
        %!pattern-cache{$pattern} //= do {
            my Bool \repeat-x = ? ($pattern.repetition eq 'repeat'|'repeat-x');
            my Bool \repeat-y = ? ($pattern.repetition eq 'repeat'|'repeat-y');
            my Bool \tiling = repeat-x || repeat-y;
            my $image = Cairo::Image.create(.Blob)
                with $pattern.image;
            if !tiling {
                # not tiling; simple image will suffice
                Cairo::Pattern::Surface.create($image.surface);
            }
            else {
                constant BigPad = 1000;
                my $width = $image.width;
                my $height = $image.height;
                my $padded-img = Cairo::Image.create(
                    Cairo::FORMAT_ARGB32,
                    $width + (repeat-x ?? 0 !! BigPad),
                    $height + (repeat-y ?? 0 !! BigPad));
                my Cairo::Context $ctx .= new($padded-img);
                $ctx.set_source_surface($image);
                $ctx.paint;
                my Cairo::Pattern::Surface $patt .= create($padded-img.surface);
                $patt.extend = Cairo::Extend::EXTEND_REPEAT;
                $patt;
            }
        }
    }
    method !make-gradient(HTML::Canvas::Gradient $gradient --> Cairo::Pattern) {
        my @color-stops;
        for $gradient.colorStops.sort(*.offset) {
            my @rgb = (.r, .g, .b).map: (*/255)
                with .color;
            @color-stops.push: %( :offset(.offset), :@rgb );
        };
        @color-stops.push({ :rgb[1, 1, 1] })
            unless @color-stops;
        @color-stops[0]<offset> = 0.0;

        my $patt = do given $gradient.type {
            when 'Linear' {
              Cairo::Pattern::Gradient::Linear.create(.x0, .y0, .x1, .y1)
                  with $gradient;
            }
            when 'Radial' {
                Cairo::Pattern::Gradient::Radial.create(.x0, .y0, .r0, .x1, .y1, .r1)
                    with $gradient;
            }
        }
        $patt.add_color_stop_rgb(.<offset>, |.<rgb>)
            for @color-stops;
        $patt;
    }
    method !make-color($_, $color) {
	when HTML::Canvas::Pattern {
            $!ctx.pattern: self!make-pattern($_);
	}
	when HTML::Canvas::Gradient {
            $!ctx.pattern: self!make-gradient($_);
	}
	default {
	    with $color {
		my Numeric @rgba[4] = .rgba.map: ( */255 );
                @rgba[3] *= $!canvas.globalAlpha;
		$!ctx.rgba(|@rgba);
	    }
        }
    }
    method fillStyle($_) {
        self!make-color($_, $!canvas.css.background-color);
    }
    method strokeStyle($_) {
        self!make-color($_, $!canvas.css.color);
    }
    method scale(Numeric \x, Numeric \y) { $!ctx.scale(x, y); }
    method rotate(Numeric \r) { $!ctx.rotate(r) }
    method translate(Numeric \x, Numeric \y) { $!ctx.translate(x, y) }
    method transform(Num(Cool) $xx, Num(Cool) $yx, Num(Cool) $xy, Num(Cool) $yy, Num(Cool) $x0, Num(Cool) $y0) {
        my Cairo::Matrix $matrix .= new.init: :$xx, :$yx, :$xy, :$yy, :$x0, :$y0;
        $!ctx.transform( $matrix );
    }
    method setTransform(Num(Cool) $xx, Num(Cool) $yx, Num(Cool) $xy, Num(Cool) $yy, Num(Cool) $x0, Num(Cool) $y0) {
        my Cairo::Matrix $matrix .= new.init: :$xx, :$yx, :$xy, :$yy, :$x0, :$y0;
        $!ctx.matrix = $matrix;
    }
    method rect(Numeric \x, Numeric \y, Numeric \w, Numeric \h ) {
        $!ctx.rectangle(x, y, w, h );
        $!ctx.close_path;
    }
    method fillRect(Numeric \x, Numeric \y, Numeric \w, Numeric \h ) {
        $!ctx.rectangle(x, y, w, h );
        $!ctx.fill;
    }
    method strokeRect(Numeric \x, Numeric \y, Numeric \w, Numeric \h ) {
        $!ctx.rectangle(x, y, w, h );
        $!ctx.stroke;
    }
    method clearRect(Numeric \x, Numeric \y, Numeric \w, Numeric \h) {
        # stub - should etch a clipping path. not paint a white rectangle
        $!ctx.save;
        $!ctx.rgb(1,1,1);
        self.fillRect(x, y, w, h);
        $!ctx.restore;
    }

    method font(Str $?) {
        $!font.css = $!canvas.css;
        $!ctx.set_font_size( $!canvas.adjusted-font-size($!font.em) );
        $!ctx.set_font_face( $!font.font-obj );
    }
    method !baseline-shift {
	my \t = $!ctx.text_extents("Q");

	given $!canvas.textBaseline {
	    when 'alphabetic'  { 0 }
	    when 'top'         { - t.y_bearing }
	    when 'bottom'      { -(t.height + t.y_bearing) }
	    when 'middle'      { -(t.height/2 + t.y_bearing) }
	    when 'ideographic' { 0 }
	    when 'hanging'     { - t.y_bearing }
	    default            { 0 }
	}
    }
    method textBaseline($) { }
    method !align(Str $text) {
	my HTML::Canvas::Baseline $baseline = $!canvas.textBaseline;
        my HTML::Canvas::TextAlignment $align = do given $!canvas.textAlign {
            when 'start' { $!canvas.direction eq 'ltr' ?? 'left' !! 'right' }
            when 'end'   { $!canvas.direction eq 'rtl' ?? 'left' !! 'right' }
            default { $_ }
        }
	my $text-extents = $!ctx.text_extents($text);
	my $dx = - $text-extents.width * %( :left(0.0), :center(0.5), :right(1.0) ){$align};
	my $dy = self!baseline-shift;
	($dx, $dy);
    }
    method textAlign($) { }
    method direction(Str $_) {}
    method fillText(Str $text, Numeric $x, Numeric $y, Numeric $maxWidth?) {
	my ($dx, $dy) = self!align($text);
	$!ctx.move_to($x + $dx, $y + $dy);
        $!ctx.show_text($text);
    }
    method strokeText(Str $text, Numeric $x, Numeric $y, Numeric $maxWidth?) {
	my ($dx, $dy) = self!align($text);
	$!ctx.save;
	$!ctx.new_path;
	$!ctx.move_to($x + $dx, $y + $dy);
        $!ctx.text_path($text);
	$!ctx.stroke;
	$!ctx.restore;
    }
    method fill() {
	$!ctx.fill;
    }
    method arc(Numeric \x, Numeric \y, Numeric \r,
               Numeric \startAngle, Numeric \endAngle, Bool $negative = False) {
        $!ctx.arc(:$negative, x, y, r, startAngle, endAngle);
    }
    method beginPath {
	$!ctx.new_path;
    }
    method lineWidth(Numeric $width) {
        $!ctx.line_width = $width;
    }
    method getLineDash() {}
    method setLineDash(List $pattern) {
        $!ctx.set_dash($pattern, +$pattern, $!canvas.lineDashOffset)
    }
    method measureText(Str $text --> Numeric) {
        $!ctx.text_extents($text).width;
    }
    method moveTo(Numeric \x, Numeric \y) { $!ctx.move_to(x, y) }
    method lineTo(Numeric \x, Numeric \y) { $!ctx.line_to(x, y) }
    method stroke {
        $!ctx.stroke
    }
    method lineCap(HTML::Canvas::LineCap $cap-name) {
        my $lc = %( :butt(Cairo::LineCap::LINE_CAP_BUTT), :round(Cairo::LineCap::LINE_CAP_ROUND),  :square(Cairo::LineCap::LINE_CAP_SQUARE)){$cap-name};
        $!ctx.line_cap = $lc;
    }
    method lineJoin(HTML::Canvas::LineJoin $join-name) {
        my $lc = %( :miter(Cairo::LineJoin::LINE_JOIN_MITER), :round(Cairo::LineJoin::LINE_JOIN_ROUND),  :bevel(Cairo::LineJoin::LINE_JOIN_BEVEL)){$join-name};
        $!ctx.line_join = $lc;
    }
    method clip() {
        $!ctx.clip;
    }
    has Cairo::Surface %!canvas-cache{HTML::Canvas};
    has Cairo::Surface %!canvas-surface-cache{HTML::Canvas::Image};
    method !canvas-to-surface(HTML::Canvas $sub-canvas, Numeric :$width!, Numeric :$height! ) {
        %!canvas-cache{$sub-canvas} //= do {
            my $renderer = self.new: :$width, :$height;
            $sub-canvas.render($renderer);
            $renderer.surface;
        }
    }
    my subset Drawable where HTML::Canvas|HTML::Canvas::Image|HTML::Canvas::ImageData;
    method !to-surface(Drawable $_,
                        :$width! is rw,
                        :$height! is rw --> Cairo::Surface) {
        when HTML::Canvas {
            $width = $_ with .html-width;
            $height = $_ with .html-height;
            self!canvas-to-surface($_, :$width, :$height);
        }
        when HTML::Canvas::ImageData {
            $width = .sw;
            $height = .sh;
            .image;
        }
        when .image-type eq 'PNG' {
            with (%!canvas-surface-cache{$_} //= Cairo::Image.create(.Blob)) {
                $width = .width;
                $height = .height;
                $_
            }
        }
        default {
            # Something we can't handle; JPEG, GIF etc.
            # create place-holder
            my Cairo::Image $image = Cairo::Image.create(Cairo::FORMAT_ARGB32, $width, $height);
            my $ctx = Cairo::Context.new($image);
            $ctx.rgba(.9, .95, .95, .4);
            $ctx.paint;
            $image;
        }
    }
    multi method drawImage( Drawable $obj, Numeric \sx, Numeric \sy, Numeric \sw, Numeric \sh, Numeric \dx, Numeric \dy, Numeric \dw, Numeric \dh) {
        unless sw =~= 0 || sh =~= 0 {
            $!ctx.save;
            # position at top right of visible area
            $!ctx.translate(dx, dy);
            # clip to visible area
            $!ctx.rectangle: 0, 0, dw, dh;
            $!ctx.close_path;
            $!ctx.clip;
            $!ctx.new_path;

            my \x-scale = dw / sw;
            my \y-scale = dh / sh;
            $!ctx.translate( -sx * x-scale, -sy * y-scale )
                if sx || sy;

            my Numeric $width = dw;
            my Numeric $height = dh;
            my Cairo::Surface $surface = self!to-surface($obj, :$width, :$height);

            $!ctx.scale(x-scale, y-scale);
            $!ctx.set_source_surface($surface);
            $!ctx.paint_with_alpha($!canvas.globalAlpha);
            $!ctx.restore;
        }
    }
    multi method drawImage(Drawable $obj, Numeric $dx, Numeric $dy, Numeric $dw?, Numeric $dh?) is default {

        my Numeric $width = $dw;
        my Numeric $height = $dh;
        my Cairo::Surface $surface = self!to-surface($obj, :$width, :$height);

        $!ctx.save;
        $!ctx.translate($dx, $dy);
        my \x-scale = do with $dw { $_ / $width } else { 1.0 };
        my \y-scale = do with $dh { $_ / $height } else { 1.0 };
        $!ctx.scale(x-scale, y-scale);
        $!ctx.set_source_surface($surface);
        $!ctx.paint_with_alpha($!canvas.globalAlpha);

	$!ctx.restore
    }
    method putImageData(HTML::Canvas::ImageData $image-data, Numeric $dx, Numeric $dy) { self.drawImage( $image-data, $dx, $dy)}
    method quadraticCurveTo(Numeric \cp1x, Numeric \cp1y, Numeric \x, Numeric \y) {
        my \cp2x = cp1x + 2/3 * (x - cp1x);
        my \cp2y = cp1y + 2/3 * (y - cp1y);
        $!ctx.curve_to( cp1x, cp1y, cp2x, cp2y, x, y);
     }
     method bezierCurveTo(Numeric \cp1x, Numeric \cp1y, Numeric \cp2x, Numeric \cp2y, Numeric \x, Numeric \y) {
        $!ctx.curve_to( cp1x, cp1y, cp2x, cp2y, x, y);
    }
    method globalAlpha(Numeric) { }

    method DESTROY {
        .destroy with $!ctx;
        $!ctx = Nil;
    }
}
