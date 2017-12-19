use v6;
use HTML::Canvas::Image;

class HTML::Canvas::Pattern {
    use JSON::Fast;
    subset Repetition of Str where 'repeat'|'repeat-x'|'repeat-y'|'no-repeat';
    has Repetition $.repetition = 'repeat';
    has HTML::Canvas::Image $.image;

    method to-js(Str $ctx, :$sym = my %{Any} --> Array) {
        my $image-js = $sym{$!image} // $!image.js-ref;
        my @js = '%s.createPattern(%s, %s)'.sprintf($ctx, $image-js, to-json($!repetition));
        @js;
    }
 }
