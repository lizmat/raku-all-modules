use v6;
use Cairo;
use JSON::Fast;

class HTML::Canvas::ImageData {
    has Cairo::Image $.image;
    has Numeric ($.sx, $.sy, $.sw, $.sh);

    method to-js(Str $ctx, --> Array) {
        my @js = '%s.getImageData(%s, %s, %s, %s)'.sprintf($ctx, |($!sx, $!sy, $!sw, $!sh).map: { to-json($_) });
        @js;
    }
 }
