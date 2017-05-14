use v6;

unit class CPAN::Uploader::Tiny::MultiPart;

has $.boundary = 'xYzZY';
has @!content;
has @!file;

my $CRLF = "\x0d\x0a".encode;

method add-content($name, $value) {
    @!content.push: $name, $value;
}

method add-file($name, *%opt) {
    @!file.push: $name, %opt;
}

method finalize() {
    my $out = buf8.new;
    for @!content -> $name, $value {
        $out ~= [~] (
            "--$!boundary".encode, $CRLF,
            qq{Content-Disposition: form-data; name="$name"}.encode, $CRLF,
            $CRLF,
            $value.encode,
            $CRLF,
        );
    }
    for @!file -> $name, %opt {
        my $content = %opt<content>;
        $content .= encode if $content !~~ Buf;
        my $filename = %opt<filename>;
        my $content-type = %opt<content-type> || 'text/plain';
        $out ~= [~] (
            "--{$!boundary}".encode, $CRLF,
            qq{Content-Disposition: form-data; name="$name"; filename="$filename"}.encode, $CRLF,
            "Content-Type: $content-type".encode, $CRLF,
            $CRLF,
            $content,
            $CRLF,
        );
    }
    $out ~= "--{$!boundary}--".encode ~ $CRLF;
    ($!boundary, $out);
}
