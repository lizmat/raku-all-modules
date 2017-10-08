use XML::Writer;

class SVG is XML::Writer {
    method serialize(*@pos, :$preamble = True, *%named) {
        my $arg = (@pos, %named.pairs).flat.grep({ $_ }).[0];
        my @preamble =
            'xmlns'         => 'http://www.w3.org/2000/svg',
            'xmlns:svg'     => 'http://www.w3.org/2000/svg',
            'xmlns:xlink'   => 'http://www.w3.org/1999/xlink',
            ;
        if $preamble {
            $arg = $arg.key => [ flat @preamble, $arg.value.flat];
        }
        self.XML::Writer::serialize($arg);
    }
}
