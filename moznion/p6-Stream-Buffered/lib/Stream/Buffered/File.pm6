use v6;
use Stream::Buffered;
use File::Temp;

unit class Stream::Buffered::File is Stream::Buffered;

has IO::Handle $!fh;

submethod BUILD(:$fh) {
    $!fh = $fh;
}

method new() {
    my ($filename, $fh) = tempfile;
    self.bless(:$fh);
}

method print(Stream::Buffered::File:D: *@text) returns Bool {
    return $!fh.print(@text);
}

method size(Stream::Buffered::File:D:) returns Int {
    $!fh.flush;

    # TODO workaround. Bad performance and ambiguous.
    # $!fh.s # <= I wish I could use this...
    my $orig = $!fh.tell;
    $!fh.seek(0, 0); # rewind
    my $size = $!fh.slurp-rest.encode.elems;
    $!fh.seek($orig, 0); # roll back the position

    return $size;
}

method rewind(Stream::Buffered::File:D:) returns IO::Handle {
    $!fh.seek(0, 0);
    return $!fh;
}

