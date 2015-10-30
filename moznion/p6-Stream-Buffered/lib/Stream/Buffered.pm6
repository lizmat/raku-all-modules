use v6;

unit class Stream::Buffered;

method new(Int $length, Int $maxMemoryBufferSize = 1024 * 1024) returns Stream::Buffered {
    # $maxMemoryBufferSize = 0  -> Always temp file
    # $maxMemoryBufferSize = -1 -> Always Blob
    my $backend;
    if $maxMemoryBufferSize < 0 {
        $backend = "Blob";
    } elsif $maxMemoryBufferSize === 0 {
        $backend = "File";
    } elsif $length === 0 {
        $backend = "Auto";
    } elsif $length > $maxMemoryBufferSize {
        $backend = "File";
    } else {
        $backend = "Blob";
    }

    return Stream::Buffered.create($backend, :$maxMemoryBufferSize);
}

method create(Stream::Buffered:U: Str $backend, Int :$maxMemoryBufferSize) {
    require ::("Stream::Buffered::$backend");
    return ::("Stream::Buffered::$backend").new(:$maxMemoryBufferSize);
}

method print(Stream::Buffered:D: *@text) returns Bool { ... }

method size(Stream::Buffered:D:) returns Int { ... }

method rewind(Stream::Buffered:D:) returns IO::Handle { ... }

=begin pod

=head1 NAME

Stream::Buffered - Temporary buffer to save bytes

=head1 SYNOPSIS

    use Stream::Buffered;

    my $buf = Stream::Buffered.new($length);

    $buf.print("foo");
    my Int $size = $buf.size;
    my IO::Handle $io = $buf.rewind;

=head1 DESCRIPTION

Stream::Buffered is a buffer class to store arbitrary length of byte
strings and then get a seekable IO::Handle once everything is buffered.
It uses Blob and temporary file to save the buffer depending on the length of the size.

This library is a perl6 port of L<perl5's Stream::Buffered|https://metacpan.org/pod/Stream::Buffered>.

=head1 METHODS

=head2 C<new(Int $length, Int $maxMemoryBufferSize = 1024 * 1024) returns Stream::Buffered>

Creates instance.

When you specify negative value as C<$maxMemoryBufferSize>, Stream::Buffered always uses Blob as buffer.
Or when you specify 0 as C<$maxMemoryBufferSize>, Stream::Buffered always uses temporary file as buffer.

If you pass 0 to the first argument, Stream::Buffered decides what kind of buffer type (Blob or temp file)
to use automatically.

=head2 C<print(Stream::Buffered:D: *@text) returns Bool>

Append text to buffer.

=head2 C<size(Stream::Buffered:D:) returns Int>

Return the size of buffer.

=head2 C<rewind(Stream::Buffered:D:) returns IO::Handle>

Seek to the head of buffer and return buffer.

=head1 SEE ALSO

=item L<perl5's Stream::Buffered|https://metacpan.org/pod/Stream::Buffered>

=head1 AUTHOR

moznion <moznion@gmail.com>

=head1 COPYRIGHT AND LICENSE

    Copyright 2015 moznion

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

And original perl5's Stream::Buffered is

    The following copyright notice applies to all the files provided in
    this distribution, including binary files, unless explicitly noted
    otherwise.

    Copyright 2009-2011 Tatsuhiko Miyagawa

    This library is free software; you can redistribute it and/or modify
    it under the same terms as Perl itself.

=end pod

