use Net::HTTP::Interfaces;
use Net::HTTP::Utils;

my $CRLF = Buf.new(13, 10);

class Net::HTTP::Response does Response {
    has $.status-line;
    has %.header;
    has $.body is rw;
    has %.trailer;

    proto method new(|) {*}
    multi method new(:$status-line, :%header, :$body, :%trailer, *%_) {
        self.bless(:$status-line, :%header, :$body, :%trailer, |%_);
    }
    multi method new(Blob $raw, *%_) {
        # Decodes headers to a string, and leaves the body as binary
        # i.e. `::("$?CLASS").new($socket.recv(:bin))`
        my $sep = buf8.new($CRLF.contents.Slip xx 2);
        my $sep-bytes = $sep.bytes;

        my $split-at = $raw.grep(*, :k).first({ $raw.subbuf($^a..($^a + $sep-bytes - 1)) eqv $sep }, :k);

        my $hbuf := $raw.subbuf(0, $split-at + $sep-bytes);
        my $bbuf := $raw.subbuf($split-at + $sep-bytes);
        my @header-lines = $hbuf.decode('latin-1').split($CRLF.decode).grep(*.so);

        # If the status-line was passed in as a named argument, then we assume its not also in @headers.
        # Otherwise we will use the first line of @headers if it matches a status-line like string.
        my $status-line = %_<status-line> // (@header-lines.shift if @header-lines[0] ~~ self!status-line-matcher);

        my %header andthen do { %header{.[0]}.append(.[1].trim-leading) for @header-lines>>.split(':', 2) }

        samewith(:$status-line, :%header, :body($bbuf), |%_);
    }


    method status-code { $!status-line ~~ self!status-line-matcher andthen return ~$_[0] }
    method !status-line-matcher { $ = rx/^ 'HTTP/' \d [\.\d]? \s (\d\d\d) \s/ }
}

# I'd like to put this in Net::HTTP::Utils, but there is problem with it being loaded late
role ResponseBodyDecoder {
    has $.enc-via-header;
    has $.enc-via-body;
    has $.enc-via-bom;
    has $.enc-via-force;
    has $!sniffed;

    method content-encoding {
        return $!sniffed if $!sniffed;
        self.content;
        $!sniffed;
    }

    method content(Bool :$force) {
        with self.header<Content-Type> {
            $!enc-via-header := .map({ sniff-content-type($_) }).first(*)
        }
        with self.body { $!enc-via-body := sniff-meta($_) }
        with self.body { $!enc-via-bom  := sniff-bom($_)  }

        # try our informed guess
        with $!enc-via-header { try { return self.body.decode($!sniffed = $_) } }
        with $!enc-via-body   { try { return self.body.decode($!sniffed = $_) } }
        with $!enc-via-bom    { try { return self.body.decode($!sniffed = $_) } }

        # fuck it take a wild guess
        if ?$force {
            try { $!enc-via-force = $!sniffed = 'utf-8';   return self.body.decode('utf-8')   }
            try { $!enc-via-force = $!sniffed = 'latin-1'; return self.body.decode('latin-1') }
        }

        die "Don't know how to decode this content; call with the `:force` argument to try harder";
    }

    sub sniff-content-type(Str $header) {
        if $header ~~ /[:i 'charset=' <q=[\'\"]>? $<charset>=<[a..z A..Z 0..9 \- \_ \.]>+ $<q>?]/ {
            my $charset = ~$<charset>;
            return $charset.lc;
        }
    }

    multi sub sniff-meta(Buf $body) {
        samewith($body.subbuf(0,512).decode('latin-1'));
    }
    multi sub sniff-meta(Str $body) {
        if $body ~~ /[:i '<' \s* meta \s* [<-[\>]> .]*? 'charset=' <q=[\'\"]>? $<charset>=<[a..z A..Z 0..9 \- \_ \.]>+ $<q>? .*? '>' ]/ {
            my $charset = ~$<charset>;
            return $charset.lc;
        }
    }

    multi sub sniff-bom(Str $data) { }
    multi sub sniff-bom(Blob $data) {
        given $data.subbuf(0,4).decode('latin-1') {
            when /^ 'ÿþ␀␀'  / { return 'utf-32-le'     } # no test
            when /^ '␀␀þÿ'  / { return 'utf-32-be'     } # no test
            when /^ 'þÿ'   / { return 'utf-16-be'     }
            when /^ 'ÿþ'   / { return 'utf-16-le'     }
            when /^ 'ï»¿'  / { return 'utf-8'         }
            when /^ '÷dL'  / { return 'utf-1'         } # no test
            when /^ 'Ýsfs' / { return 'utf-ebcdic'    } # no test
            when /^ '␎þÿ'   / { return 'scsu'          } # no test
            when /^ 'ûî('  / { return 'bocu-1'        } # no test
            when /^ '„1•3' / { return 'gb-18030'      } # test marked :todo :(
            when /^ '+/v' <[89/+]> / { return 'utf-7' }
        }
    }
}