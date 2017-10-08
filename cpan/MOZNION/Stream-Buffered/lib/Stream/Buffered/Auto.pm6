use v6;
use Stream::Buffered;

unit class Stream::Buffered::Auto is Stream::Buffered;

has Stream::Buffered $!buffer;
has Int $!maxMemoryBufferSize;

submethod BUILD(:$buffer, :$maxMemoryBufferSize) {
    $!buffer              = $buffer;
    $!maxMemoryBufferSize = $maxMemoryBufferSize;
}

method new(:$maxMemoryBufferSize!) {
    self.bless(
        :buffer(Stream::Buffered.create('Blob')),
        :maxMemoryBufferSize($maxMemoryBufferSize)
    );
}

method print(Stream::Buffered::Auto:D: *@text) returns Bool {
    my $status = $!buffer.print(@text);

    if $!maxMemoryBufferSize && $!buffer.size > $!maxMemoryBufferSize {
        my $written = $!buffer.rewind.slurp-rest;
        $!buffer = Stream::Buffered.create('File');

        $status = $!buffer.print($written);

        $!maxMemoryBufferSize = Nil;
    }

    return $status;
}

method size(Stream::Buffered::Auto:D:) returns Int {
    return $!buffer.size;
}

method rewind(Stream::Buffered::Auto:D:) returns IO::Handle {
    return $!buffer.rewind;
}

