use v6;

class HTML::Canvas:ver<0.0.2> {
    use CSS::Declarations:ver;
    use HTML::Canvas::Gradient;
    use HTML::Canvas::Pattern;
    use HTML::Canvas::Image;
    use HTML::Canvas::ImageData;
    use HTML::Entity;
    has Numeric @.transformMatrix is rw = [ 1, 0, 0, 1, 0, 0, ];
    has Numeric $.width = 612;
    has Numeric $.height = 792;
    has Pair @.subpath;
    has Str @!subpath-new;
    has Pair @.calls;
    has Routine @.callback;
    has $!cairo  = (require ::('HTML::Canvas::To::Cairo')).new: :canvas(self), :$!width, :$!height;
    method image { $!cairo.surface }
    subset LValue of Str where 'dashPattern'|'fillStyle'|'font'|'lineCap'|'lineJoin'|'lineWidth'|'strokeStyle'|'textAlign'|'textBaseline'|'direction'|'globalAlpha';
    my subset PathOps of Str where 'moveTo'|'lineTo'|'quadraticCurveTo'|'bezierCurveTo'|'arcTo'|'arc'|'rect'|'closePath';
    my subset CanvasOrImage where HTML::Canvas|HTML::Canvas::Image;

    has Numeric $.lineWidth = 1.0;
    method lineWidth is rw {
        Proxy.new(
            FETCH => sub ($) { $!lineWidth },
            STORE => sub ($, $!lineWidth) {
                self!call('lineWidth', $!lineWidth);
            }
        );
    }

    has Numeric $.globalAlpha = 1.0;
    method globalAlpha is rw {
        Proxy.new(
            FETCH => sub ($) { $!globalAlpha },
            STORE => sub ($, $!globalAlpha) {
                self!call('globalAlpha', $!globalAlpha);
            }
        );
    }

    has Numeric @.lineDash;
    has Numeric $.lineDashOffset = 0.0;
    method lineDashOffset is rw {
        Proxy.new(
            FETCH => sub ($) { $!lineDashOffset },
            STORE => sub ($, $!lineDashOffset) {
                self!call('lineDashOffset', $!lineDashOffset);
            }
        );
    }
    subset LineCap of Str where 'butt'|'round'|'square';
    has LineCap $.lineCap = 'butt';
    method lineCap is rw {
        Proxy.new(
            FETCH => sub ($) { $!lineCap },
            STORE => sub ($, $!lineCap) {
                self!call('lineCap', $!lineCap);
            }
        );
    }
    subset LineJoin of Str where 'bevel'|'round'|'miter';
    has LineJoin $.lineJoin = 'bevel';
    method lineJoin is rw {
        Proxy.new(
            FETCH => sub ($) { $!lineJoin },
            STORE => sub ($, $!lineJoin) {
                self!call('lineJoin', $!lineJoin);
            }
        );
    }
    has Str $.font = '10pt times-roman';
    method font is rw {
        Proxy.new(
            FETCH => sub ($) { $!font },
            STORE => sub ($, Str $!font) {
                $!css.font = $!font;
                self!call('font', $!font);
            }
        );
    }
    #| browsers seem to be display fonts at 4/3 of actual size. Not sure
    #| if this should be treated as UI dependant.
    method adjusted-font-size(Numeric $raw-size) {
        $raw-size * 4/3;
    }

    subset Baseline of Str where 'alphabetic'|'top'|'hanging'|'middle'|'ideographic'|'bottom';
    has Baseline $.textBaseline = 'alphabetic';
    method textBaseline is rw {
        Proxy.new(
            FETCH => sub ($) { $!textBaseline },
            STORE => sub ($, Str $!textBaseline) {
                self!call('textBaseline', $!textBaseline);
            }
        );
    }

    subset TextAlignment of Str where 'start'|'end'|'left'|'right'|'center';
    has TextAlignment $.textAlign = 'start';
    method textAlign is rw {
        Proxy.new(
            FETCH => sub ($) { $!textAlign },
            STORE => sub ($, Str $!textAlign) {
                self!call('textAlign', $!textAlign);
            }
        );
    }

    subset TextDirection of Str where 'ltr'|'rtl';
    has TextDirection $.direction = 'ltr';
    method direction is rw {
        Proxy.new(
            FETCH => sub ($) { $!direction },
            STORE => sub ($, Str $!direction) {
                self!call('direction', $!direction);
            }
        );
    }

    subset ColorSpec where Str|HTML::Canvas::Gradient|HTML::Canvas::Pattern;
    has ColorSpec $.fillStyle is rw = 'black';
    method fillStyle is rw {
        Proxy.new(
            FETCH => sub ($) { $!fillStyle },
            STORE => sub ($, ColorSpec $!fillStyle) {
                $!css.background-color = $!fillStyle
                    if $!fillStyle ~~ Str;
                self!call('fillStyle', $!fillStyle);
            }
        );
    }
    has ColorSpec $.strokeStyle is rw = 'black';
    method strokeStyle is rw {
        Proxy.new(
            FETCH => sub ($) { $!strokeStyle },
            STORE => sub ($, ColorSpec $!strokeStyle) {
                $!css.color = $!strokeStyle
                    if $!strokeStyle ~~ Str;
                self!call('strokeStyle', $!strokeStyle);
            }
        );
    }

    has CSS::Declarations $.css = CSS::Declarations.new( :background-color($!fillStyle), :color($!strokeStyle), :$!font,  );
    has @.gsave;

    method TWEAK {
    }

    our %API = BEGIN %(
        :_start(method {} ),
        :_finish(method {
                        warn "{@!subpath-new.join: ', '} not followed by fill() or stroke() at end of canvas context"
                            if @!subpath-new;
                        @!subpath = [];

                        die "'save' unmatched by 'restore' at end of canvas context"
                            if @!gsave;
                    } ),
        :save(method {
                     my @ctm = @!transformMatrix;
		     my @path = @!subpath;
                     @!gsave.push: {
                         :@ctm,
			 :@path,
                         :$!strokeStyle,
                         :$!fillStyle,
			 :$!globalAlpha,
			 :$!lineWidth,
			 :$!lineCap,
			 :$!lineJoin,
			 :$!font,
                         :$!textAlign,
                         :$!direction,
			 :$!textBaseline,
                         :$!css,
                     };
                     $!css = $!css.new: :copy($!css);
                 } ),
        :restore(method {
                        if @!gsave {
                            my %state = @!gsave.pop;

                            @!transformMatrix = %state<ctm>.list;
                            @!subpath = %state<path>.list;
                            $!strokeStyle = %state<strokeStyle>;
                            $!fillStyle = %state<fillStyle>;
                            $!globalAlpha = %state<globalAlpha>;
                            $!lineWidth = %state<lineWidth>;
                            $!lineCap = %state<lineCap>;
                            $!lineJoin = %state<lineJoin>;
			    $!font = %state<font>;
                            $!textAlign = %state<textAlign>;
                            $!direction = %state<direction>;
                            $!textBaseline = %state<textBaseline>;
                            $!css = %state<css>;
                        }
                        else {
                            warn "restore without preceding save";
                        }
                } ),
        :scale(method (Numeric $x, Numeric $y) {
                      with @!transformMatrix {
                          $_ *= $x for .[0], .[1];
                          $_ *= $y for .[2], .[3];
                      }
                  }),
        :rotate(method (Numeric $rad) {
                       my \c = cos($rad);
                       my \s = sin($rad);
                       with @!transformMatrix {
                           .[0..3] = [
                               .[0] * +c + .[2] * s,
                               .[1] * +c + .[3] * s,
                               .[0] * -s + .[2] * c,
                               .[1] * -s + .[3] * c,
                           ]
 
                       }
                  }),
        :translate(method (Numeric $x, Numeric $y) {
                          with @!transformMatrix {
                              .[4] += .[0] * $x + .[2] * $y;
                              .[5] += .[1] * $x + .[3] * $y;
                          }
                  }),
        :transform(method (Numeric \a, Numeric \b, Numeric \c, Numeric \d, Numeric \e, Numeric \f) {
                          @!transformMatrix = do with @!transformMatrix {
                              [
                                  .[0] * a + .[2] * b,
                                  .[1] * a + .[3] * b,

                                  .[0] * c + .[2] * d,
                                  .[1] * c + .[3] * d,

                                  .[0] * e + .[2] * f + .[4],
                                  .[1] * e + .[3] * f + .[5],
                              ];
                          }
                      }),
        :setTransform(method (Numeric \a, Numeric \b, Numeric \c, Numeric \d, Numeric \e, Numeric \f) {
                             @!transformMatrix = [a, b, c, d, e, f];
                         }),
        :clearRect(method (Numeric $x, Numeric $y, Numeric $w, Numeric $h) { }),
        :fillRect(method (Numeric $x, Numeric $y, Numeric $w, Numeric $h) {
                         self!setup-fill();
                     }),
        :strokeRect(method (Numeric $x, Numeric $y, Numeric $w, Numeric $h) {
                           self!setup-stroke();
         }),
        :beginPath(method () { @!subpath = @!subpath-new = []; }),
        :fill(method () {
                     self!setup-fill();
                     self!draw-subpath()
                 }),
        :stroke(method () {
                       self!setup-stroke();
                       self!draw-subpath()
                   }),
        :clip(method () {
                     self!draw-subpath();
                 }),
        :fillText(method (Str $text, Numeric $x, Numeric $y, Numeric $max-width?) {
                         self!setup-fill();
                     }),
        :strokeText(method (Str $text, Numeric $x, Numeric $y, Numeric $max-width?) {
                           self!setup-stroke();
                       }),
        :drawImage(method (CanvasOrImage \image, Numeric \dx, Numeric \dy, *@args) {
                          self!register-node(image);
                   }),
        :putImageData(method (HTML::Canvas::ImageData \image-data, Numeric \dx, Numeric \dy, *@args) {
                          self!register-node(image-data);
                      }),
        # :setLineDash - see below
        :getLineDash(method () { @!lineDash } ),
        :closePath(method () {}),
        :moveTo(method (Numeric \x, Numeric \y) {} ),
        :lineTo(method (Numeric \x, Numeric \y) {} ),
        :quadraticCurveTo(method (Numeric \cp1x, Numeric \cp1y, Numeric \x, Numeric \y) {} ),
        :bezierCurveTo(method (Numeric \cp1x, Numeric \cp1y, Numeric \cp2x, Numeric \cp2y, Numeric \x, Numeric \y) {} ),
        :rect(method (Numeric $x, Numeric $y, Numeric $w, Numeric $h) { }),
        :arc(method (Numeric $x, Numeric $y, Numeric $radius, Numeric $startAngle, Numeric $endAngle, Bool $counterClockwise?) { }),
    );

    method createLinearGradient(Numeric $x0, Numeric $y0, Numeric $x1, Numeric $y1) {
        self!var: HTML::Canvas::Gradient.new: :$x0, :$y0, :$x1, :$y1;
    }
    method createRadialGradient(Numeric $x0, Numeric $y0, Numeric $r0, Numeric $x1, Numeric $y1, Numeric:D $r1) {
        self!var: HTML::Canvas::Gradient.new: :$x0, :$y0, :$r0, :$x1, :$y1, :$r1;
    }
    method createPattern(HTML::Canvas::Image $image, HTML::Canvas::Pattern::Repetition $repetition = 'repeat') {
        self!register-node($image);
        self!var: HTML::Canvas::Pattern.new: :$image, :$repetition;
    }
    method getImageData(Numeric $sx, Numeric $sy, Numeric $sw, Numeric $sh) {
        use Cairo;
        my Cairo::Image $image = Cairo::Image.create(Cairo::FORMAT_ARGB32, $sw, $sh);
        my $ctx = Cairo::Context.new($image);
        $ctx.rgb(1.0, 1.0, 1.0);
        $ctx.paint;
        $ctx.set_source_surface(self.image, -$sx, -$sy);
        $ctx.rectangle($sx, $sy, $sh, $sh);
        $ctx.paint;
        self!var: HTML::Canvas::ImageData.new: :$image, :$sx, :$sy, :$sw, :$sh;
    }
    method measureText(Str $text) {
        my @measures = @!callback.map({.('measureText', $text)}).grep: *.so;
        if @measures {
            with @measures.sum / +@measures -> $width {
                my class TextMetrics { has Numeric $.width }.new: :$width
            }
        }
    }
    # todo: slurping/itemization of @!lineDash?
    method setLineDash(@!lineDash) {
        self!call('setLineDash', @!lineDash.item);
    }
    method lineDash {
	Proxy.new(
	    FETCH => sub ($) { @!lineDash },
	    STORE => sub ($, \l) { self.setLineDash(l) },
	    )
    }
    method !var($object) {
        @!calls.push: (:$object);
        $object;
    }
    method !call(Str $name, *@args) {
        @!calls.push: ($name => @args)
            unless $name eq '_start'|'_finish';

        if $name ~~ PathOps {
            #| draw later (via $.fill or $.stroke)
            @!subpath-new.push: $name;
            @!subpath.push: ($name => @args);
        }
        elsif $name eq 'fill'|'stroke' && ! @!subpath {
            warn "no current path to $name";
        }
        else {
            .($name, |@args) for @!callback;
        }
    }
    method !setup-fill { .('fillStyle', self.fillStyle) for @!callback; }
    method !setup-stroke { .('strokeStyle', self.strokeStyle) for @!callback; }
    method !draw-subpath {

        @!subpath-new = [];
        for @!subpath -> \s {
            .(s.key, |s.value) for @!callback;
        }
    }

    method context(&do-markup) {
        self._start;
        &do-markup(self);
        self._finish;
    }

    my role HTMLObj[Str $html-id] {
        has Numeric $.html-width is rw;
        has Numeric $.html-height is rw;
        method html-id {$html-id}
        method js-ref {
            'document.getElementById("%s")'.sprintf(self.html-id);
        }
    }

    method !register-node($obj) {
        $obj.^mixin: HTMLObj[~ $obj.WHERE]
            unless $obj.does(HTMLObj);
        $obj;
    }
    #| lightweight html generation; canvas + javascript
    method to-html($obj = self, Numeric :$width = $obj.?width // Numeric, Numeric :$height = $obj.?height // Numeric, Str :$style='', |c) {
        self!register-node($obj);
        $obj.html-width   = $_ with $width;
        $obj.html-height  = $_ with $height;

        if $obj.can('html') {
            $obj.html(:$style, |c);
        }
        elsif $obj.can('data-uri') {
            sprintf "<img id='%s' style='%s' src='%s' />\n".sprintf( $obj.html-id, encode-entities($style), $obj.data-uri );
        }
        else {
            die "unable to convert this object to HTML";
        }
    }
    method html(Str :$style, Str :$sep = "\n    ", |c) is default {
        if self.does(HTMLObj) {
            my $style-att  = do with $style { encode-entities($_).fmt(' style="%s"') } else { '' };
            my $width-att  = do with self.html-width  { ' width="%dpt"'.sprintf($_) } else { '' };
            my $height-att = do with self.html-height { ' height="%dpt"'.sprintf($_) } else { '' };

            qq:to"END-HTML";
            <canvas{$width-att}{$height-att} id="{self.html-id}"{$style-att}></canvas>
            <script>
                var ctx = {self.js-ref}.getContext("2d");
                {self.js(:context<ctx>, :$sep, |c)}
            </script>
            END-HTML
        }
        else {
            die 'please call .to-html( :$width, :$height) on this canvas, to initialize it';
        }
    }

    has %.var-num;
    has %.sym{Any};
    method !check-variable($_, |c) {
        when Str|Numeric|Bool|List { }
        when HTML::Canvas::Gradient {
            %!sym{$_} //= self!declare-variable($_, |c);
        }
        when HTML::Canvas::Pattern {
            %!sym{$_} //= self!declare-variable($_, |c)
                for $_, .image;
        }
        default {
            %!sym{$_} //= self!declare-variable($_, |c)
                if .can('js-ref');
        }
    }

    method !declare-variable($obj, :$context!, :@js!) {
        my $var-name;

        my $type = do given $obj {
            when HTML::Canvas::Gradient  { 'grad_' }
            when HTML::Canvas::Pattern   { 'patt_' }
            when HTML::Canvas::ImageData { 'imgd_' }
            default { .can('js-ref') ?? 'node_' !!  Nil }
        }
        with $type {
            $var-name = $_ ~ ++%.var-num{$_};

            given $obj {
                when HTML::Canvas::Gradient {
                    @js.append: .to-js($context, $var-name);
                }
                when HTML::Canvas::Pattern|HTML::Canvas::ImageData {
                    @js.push: 'var %s = %s;'.sprintf($var-name, .to-js($context, :%!sym));
                }
                default {
                    @js.push: 'var %s = %s;'.sprintf($var-name, .js-ref);
                }
            }
        }

        $var-name;
    }

    #| generate Javascript
    method js(Str :$context = 'ctx', :$sep = "\n") {
        use JSON::Fast;
        my @js;

        # process statements (calls and assignments)
        for @!calls {
            my $name = .key;
            if $name eq 'object' {
                self!check-variable(.value, :$context, :@js);
              }
            else {
                my @args = flat .value.map: {
                    when Str|Numeric|Bool { to-json($_) }
                    when List { '[ ' ~ .map({to-json($_)}).join(', ') ~ ' ]' }
                    when %!sym{$_}:exists { %!sym{$_} }
                    when HTML::Canvas::Pattern|HTML::Canvas::Gradient|HTML::Canvas::ImageData {
                        self!check-variable($_, :$context, :@js);
                        %!sym{$_} // .to-js($context, :%!sym);
                    }
                    default {
                        self!check-variable($_, :$context, :@js);
                        %!sym{$_} // .?js-ref // die "unexpected object: {.perl}";
                    }
                }
            my \fmt = $name ~~ LValue
                ?? '%s.%s = %s;'
                !! '%s.%s(%s);';
            @js.push: fmt.sprintf( $context, $name, @args.join(", ") );
            }
        }

        @js.join: $sep;
    }

    #| rebuild the canvas, using the given renderer
    method render($renderer, :@calls = self.calls) {
        my @callback = [ $renderer.callback, ];
        my $canvas = self.new: :@callback;
        temp $renderer.canvas = $canvas;
        $canvas.context: {
            for @calls {
                with .key -> \call {
                    my \args = .value;
                    if +args && call ~~ LValue {
                        $canvas."{call}"() = args[0];
                    }
                    else {
                        $canvas."{call}"(|args);
                    }
                }
            }
        }
    }

    method can(Str \name) {
        my @meth = callsame;
        if !@meth {
            with %API{name} -> &api {
                @meth.push: method (*@a) {
                    my \r := &api(self, |@a);
                    self!call(name, |@a);
                    r;
                };
            }
            self.^add_method(name, @meth[0]) if @meth;
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
