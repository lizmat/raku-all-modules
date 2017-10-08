use v6;
use Test;
use Stream::Buffered;
use Stream::Buffered::Blob;
use Stream::Buffered::File;
use Stream::Buffered::Auto;

subtest {
    subtest {
        my $sb = Stream::Buffered.new(1024, -1);

        ok $sb.isa(Stream::Buffered::Blob);

        $sb.print("foo");
        is $sb.size, 3;

        my $io = $sb.rewind;
        is $io.slurp-rest, 'foo';
    }, 'Always Blob when maxMemoryBufferSize is negative';

    subtest {
        my $sb = Stream::Buffered.new(4, 8);

        ok $sb.isa(Stream::Buffered::Blob);

        $sb.print("foo");
        is $sb.size, 3;

        my $io = $sb.rewind;
        is $io.slurp-rest, 'foo';
    }, 'Use Blob when length is smaller than maxMemoryBufferSize';
}, 'Test for Blob';

subtest {
    subtest {
        my $sb = Stream::Buffered.new(1024, 0);

        ok $sb.isa(Stream::Buffered::File);

        $sb.print("foo");
        is $sb.size, 3;

        my $fh = $sb.rewind;
        is $fh.slurp-rest, 'foo';
    }, 'Always file when maxMemoryBufferSize is zero';

    subtest {
        my $sb = Stream::Buffered.new(8, 4);

        ok $sb.isa(Stream::Buffered::File);

        $sb.print("foo");
        is $sb.size, 3;

        my $fh = $sb.rewind;
        is $fh.slurp-rest, 'foo';
    }, 'Use file when length bigger than maxMemoryBufferSize';
}, 'Test for file';

subtest {
    my $sb = Stream::Buffered.new(0, 8);

    ok $sb.isa(Stream::Buffered::Auto);

    $sb.print("foo");
    is $sb.size, 3;

    my $io = $sb.rewind;
    is $io.slurp-rest, 'foo';
    ok $io.isa(IO::Blob);

    $sb.print("barbuz");
    is $sb.size, 9;

    my $fh = $sb.rewind;
    is $fh.slurp-rest, 'foobarbuz';
    ok !$fh.isa(IO::Blob);
    ok $fh.isa(IO::Handle);
}, 'Test for Auto';

done-testing;

