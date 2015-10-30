use Net::HTTP::Interfaces;
use Net::HTTP::Utils;

my $CRLF = "\r\n";

class Net::HTTP::Response does Response {
    has $.status-line;
    has %.header;
    has $.body is rw;
    has %.trailer;
    has $.nl = $CRLF;

    proto method new(|) {*}
    multi method new(:$status-line, :%header, :$body, :%trailer, :$nl = $CRLF, *%_) {
        self.bless(:$status-line, :%header, :$body, :%trailer, |%_);
    }
    multi method new(Blob $raw, :$nl = $CRLF, *%_) {
        # Decodes headers to a string, and leaves the body as binary
        # i.e. `::("$?CLASS").new($socket.recv(:bin))`
        my @sep      = "{$nl}{$nl}".ords;
        my $sep-size = @sep.elems;
        my $split-at = $raw.grep(*, :k).first({ $raw[$^a..($^a + $sep-size - 1)] ~~ @sep }, :k);

        my $hbuf := $raw.subbuf(0, $split-at + $sep-size);
        my $bbuf := $raw.subbuf($split-at + $sep-size);

        my @header-lines = $hbuf.unpack('A*').split($nl).grep(*.so);

        # If the status-line was passed in as a named argument, then we assume its not also in @headers.
        # Otherwise we will use the first line of @headers if it matches a status-line like string.
        my $status-line = %_<status-line> // (@header-lines.shift if @header-lines[0] ~~ self!status-line-matcher);

        my %header = @header-lines>>.split(/':' \s+/, 2)>>.hash;
        samewith(:$status-line, :%header, :body($bbuf), :$nl, |%_);
    }


    method status-code { $!status-line ~~ self!status-line-matcher andthen return ~$_[0] }
    method !status-line-matcher { $ = rx/^ 'HTTP/' \d [\.\d]? \s (\d\d\d) \s/ }
}
