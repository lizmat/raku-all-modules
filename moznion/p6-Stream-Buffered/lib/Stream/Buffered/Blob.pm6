use v6;
use Stream::Buffered;
use IO::Blob;

unit class Stream::Buffered::Blob is Stream::Buffered;

has IO::Blob $!blob;

submethod BUILD(:$blob) {
    $!blob = $blob;
}

method new() {
    self.bless(:blob(IO::Blob.new));
}

method print(Stream::Buffered::Blob:D: *@text) returns Bool {
    return $!blob.print(@text);
}

method size(Stream::Buffered::Blob:D:) returns Int {
    return $!blob.data.elems;
}

method rewind(Stream::Buffered::Blob:D:) returns IO::Handle {
    $!blob.seek(0, 0);
    return $!blob;
}

