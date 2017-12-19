class HTML::Canvas::Image {

    use Base64::Native;
    has Str $.data-uri;
    my subset Str-or-IO-Handle where Str|IO::Handle;
    has Str-or-IO-Handle $.source;
    has Str $.image-type;

    method !image-type($_, :$path!) {
        when m:i/^ jpe?g $/    { 'JPEG' }
        when m:i/^ gif $/      { 'GIF' }
        when m:i/^ png $/      { 'PNG' }
        when m:i/^ svg $/      { 'SVG' }
        when m:i/^ bmp $/      { 'BMP' }
        default {
            die "unknown image type: $path";
        }
    }

    multi method open(Str $data-uri where /^('data:' [<t=.ident> '/' <s=.ident>]? $<b64>=";base64"? $<start>=",") /) {
        my $path = ~ $0;
        my Str \mime-type = ( $0<t> // '(missing)').lc;
        my Str \mime-subtype = ( $0<s> // '').lc;
        my Bool \base64 = ? $0<b64>;
        my Numeric \start = $0<start>.to;

        die "expected mime-type 'image/*', got '{mime-type}': $path"
            unless mime-type eq 'image';
        my $image-type = self!image-type(mime-subtype, :$path);
        self.new(:$image-type, :$data-uri);
    }

    multi method open(Str $path! ) {
        self.open( $path.IO );
    }

    multi method open(IO::Path $io-path) {
        self.open( $io-path.open( :r, :bin) );
    }

    multi method open(IO::Handle $source!) {
        my $path = $source.path;
        my Str $image-type = self!image-type($path.extension, :$path);
        self.new( :$source, :$image-type,);
    }

    method Str returns Str {
        with $!source {
            .isa(Str)
                ?? .substr(0)
                !! .path.IO.slurp(:enc<latin-1>);
        }
    }

    method Blob returns Blob {
        with $!source {
            .isa(Str)
                ?? .encode("latin-1")
                !! .path.IO.slurp(:bin);
        }
    }

    method data-uri is rw {
        Proxy.new(
            FETCH => sub ($) {
                $!data-uri //= do with $.Blob {
                    my Str $enc = base64-encode($_, :str);
                    'data:image/%s;base64,%s'.sprintf($.image-type.lc, $enc);
                }
                else {
                    fail 'image is not associated with a source';
                }
            },
            STORE => sub ($, $!data-uri) {},
        )
    }
}
