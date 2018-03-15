unit class HTTP::Request::FormData:ver<0.1>:auth<github:zostay>;
use v6;

=begin pod

=head1 NAME

HTTP::Request::FormData - handler to expedite the handling of multipart/form-data requests

=head1 SYNOPSIS

    use HTTP::UserAgent;
    use HTTP::Request::Common;

    my $ua = HTTP::UserAgent.new;

    my $fd = HTTP::Request::FormData.new;
    $fd.add-part('username', 'alice');
    $fd.add-part('avatar', 'alice.png'.IO, content-type => 'image/png');

    my $req = POST(
        'http://example.com/',
        Content-Type => $fd.content-type,
        content => $fd.content,
    );

    my $res = $ua.request($req);

=head1 DESCRIPTION

This provides a structured object for use with L<HTTP::Request> that serializes
into a nice neat content buffer.

I wrote this as an expedient work-around to some encoding issues I have with the
way L<HTTP::Request> works. This may be a better way to solve that problem than
the API ported form LWP in Perl 5, but I am not making a judgement in that
regard. I was merely attempting to expedite a solution and sharing it with the
hope that it might be useful to someone else as well.

That said, this module aims at correctly rendering multipart/form-data content
according to the specification laid out in RFC 7578.

=head1 METHODS

=head2 method new

    multi method new() returns HTTP::Request::FormData:D

Constructs a new, empty form data object.

=head2 method add-part

    multi method add-part(Str:D $name, IO::Path $file, Str :$content-type, Str :$filename)
    multi method add-part(Str:D $name, IO::Handle $file, Str :$content-type, Str :$filename)
    multi method add-part(Str:D $name, $value, Str :$content-type, Str :$filename)

These methods append a new part to the end of the object. Three methods of
adding parts are provided.

Passing an L<IO::Path> will result in the given file being slurped
automatically. The part will be read as binary data unless you specify a
C<$content-type> that starts with "text/".

Similarly, an L<IO::Handle> may be passed and the contents will be slurped from
here as well. This allows you control over whether to set the binary flag or not
yourself.

Finally, you can pass an explicit value, which can be pretty much any string,
blob, or other cool value you like.

In each case, you can specify the C<$filename> to use for that part. Note that
the C<$filename> will be inferred from the given path if an L<IO::Path> is
passed.

=head2 method parts

    method parts() returns Seq:D

Returns a L<Seq> of the parts. Each part is returned as a
HTTP::Request::FormData::Part object, which provides the following accessors:

=item * C<name> This is the name of the part.
=item * C<filename> This is the filename of the part (if it is a file).
=item * C<content-type> This is the content type to use (if any).
=item * C<value> This is the value that was set when the part was added.
=item * C<content> This is the content that will be rendered with the part (derived from the C<value> with headers at the top).

=head2 method boundary

    method boundary() returns Str:D

This is an accessor that allows you to see what the boundary will be used to
separate the parts when rendered. This boundary meets the requirements of RFC
7578, which stipulates that the boundary must not be found in the content
contained within any of the parts. This means that if you add a new part, the
boundary may have to change.

For this reason, the C<add-part> method will throw an exception if you attempt
to add a part after calling this method to select a boundary.

=head2 method content-type

    method content-type() returns Str:D

This is a handy helper for generating a MIME type with the boundary parameter
like this:

    use HTTP::Request::Common;

    my $fd = HTTP::Request::FormData.new;
    $fd.add-part('name', 'alice');

    my $req = POST(
        'http://example.com/',
        Content-Type => $fd.content-type,
        content => $fd.content,
    );

It is essentially equivalent to:

    qq<multipart/formdata; boundary=$fd.boundary()>

As this calls C<boundary()>, calls to C<add-part> will throw an exception after
the first call to this method is made.

=head2 method content

    method content() returns Blob:D

This will return the serialized data associated with this form data object. Each
part will have it's headers and content rendered in order and separated by the
boundary as specified in RFC 7578.

=end pod

class Part {
    has Str $.name is required;
    has Str $.filename;
    has Str $.content-type;

    has $.value;

    method is-binary() {
        with $!content-type {
            ! .starts-with("text/")
        }
        else {
            False; # RFC 7578 says default type is "text/plain"
        }
    }

    has Blob $!content;
    method content() returns Blob:D {
        return $_ with $!content;

        my $header = qq<Content-Disposition: form-data; name="$!name">;
        $header ~= qq<; filename="$_"> with $!filename;
        $header ~= qq<\r\nContent-Type: $_> with $!content-type;
        $header ~= qq<\r\n\r\n>;

        my $blob-value = do given $!value {
            when IO::Handle { .slurp }
            when IO::Path { .slurp(:bin(self.is-binary)) }
            when Blob { $_ }
            when Str { $_ }
            default { .Str }
        }

        $blob-value .= encode unless $blob-value ~~ Blob;

        $!content = $header.encode ~ $blob-value;
    }
}

has Str $!boundary;
has Part @!parts;

multi method add-part(Str:D $name, IO::Path:D $file, Str :$content-type, Str :$filename is copy) {
    $filename //= $file.basename;

    # TODO %00 encode filename

    callwith($name, $file, :$content-type, :$filename);
}

class GLOBAL::X::HTTP::Request::FormData is Exception {
    method message() { "You may not add any more parts to multipart/form-data after boundary has been read." }
}

multi method add-part(Str:D $name, $value, Str :$content-type, Str :$filename) {
    # No adding parts after boundary is set
    $!boundary andthen X::HTTP::Request::FormData.new.throw;

    push @!parts, Part.new(:$name, :$filename, :$content-type, :$value);

    return;
}

method parts() returns Seq:D { @!parts.Seq }

my @boundary-chars = flat 'A' .. 'Z', 'a' .. 'z', '0' .. '9';
method boundary() returns Str:D {
    return $_ with $!boundary;

    my $n = 5;
    $!boundary = @boundary-chars.roll($n).join;
    BOUNDARY_SEARCH: loop {
        my $bin-boundary = $!boundary.encode;
        for @!parts.map({ .content }) -> $part {
            for $part.list.kv -> $i, $byte {

                # If any subbuf matches, our boundary is invalid. Pick a new
                # one and search again.
                if $byte == $bin-boundary[0] && $part.subbuf($i, $bin-boundary.elems) eq $bin-boundary {
                    $!boundary = @boundary-chars.roll($n *= 2).join;
                    next BOUNDARY_SEARCH;
                }
            }
        }

        # If we get here, the boundary string was not found in any part, so we
        # have a valid boundary string.
        return $!boundary;
    }
}

method content-type() returns Str:D {
    qq<multipart/form-data; boundary={self.boundary}>
}

constant CRLF = Blob.new(0xd, 0xa);
constant DASH = "--".encode;
method content() returns Blob:D {
    my $bin-boundary = $!boundary.encode;

    my Buf $content .= new;
    $content ~= DASH ~ $bin-boundary ~ CRLF ~ .content ~ CRLF for @!parts;
    $content ~= DASH ~ $bin-boundary ~ DASH ~ CRLF;

    # return as immutable
    Blob.new($content);
}
