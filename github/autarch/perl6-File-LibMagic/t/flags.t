use v6;
use lib 'lib';
use Test;

use File::LibMagic;
use File::Temp;

subtest {
    test-with-flag(
        't/samples/tiny-pdf.gz',
        { :uncompress },
        set( 'application/gzip', 'application/x-gzip' ),
        'application/pdf',
    );
}, 'gzip file with and without uncompress flag';

subtest
{
    my $dir = tempdir();
    my $link-file = $*SPEC.catfile( $dir, 'link-to-tiny.pdf' );
    $link-file.IO.symlink( IO::Path.new('t/samples/tiny.pdf').absolute );

    test-with-flag(
        $link-file,
        { :follow-symlinks },
        'inode/symlink',
        'application/pdf',
    );
}, 'symlinked file';

subtest {
    todo( q{:preserve-atime doesn't work for all cases yet}, 2 );

    my $path = IO::Path.new('t/samples/foo.c');
    my $atime = $path.accessed;

    File::LibMagic.new( :preserve-atime ).from-filename($path);
    File::LibMagic.new.from-filename( :preserve-atime, $path );

    my $handle = $path.open;
    File::LibMagic.new( :preserve-atime ).from-handle($handle);
    File::LibMagic.new.from-handle( :preserve-atime, $handle );

    is(
        $path.accessed,
        $atime,
        'atime did not change when file magic was retrieved with :preserve-atime flag'
    );

    File::LibMagic.new.from-filename($path);
    File::LibMagic.new.from-handle($handle);
    isnt(
        $path.accessed,
        $atime,
        'atime changes when :preserve-atime flag is not passed'
    );
}, 'preserve-atime flag';

# XXX - is there any sane way to test the open-devices flag?

# XXX - I'm not sure what raw does or how to test. Same with the apple flag.

sub test-with-flag ($file, %flag, $expect-without-flag, Str $expect-with-flag) {
    my %info = File::LibMagic.new.from-filename($file);

    if $expect-without-flag ~~ Set {
        cmp-ok(
            %info<mime-type>,
            '(elem)',
            $expect-without-flag,
            "file matches $expect-without-flag without flag",
        );
    }
    else {
        is(
            %info<mime-type>,
            $expect-without-flag,
            "file is $expect-without-flag without flag",
        );
    }

    %info = File::LibMagic.new(|%flag).from-filename($file);

    is(
        %info<mime-type>,
        $expect-with-flag,
        "file is $expect-with-flag with flag passed to constructor",
    );

    %info = File::LibMagic.new.from-filename( $file, |%flag );

    is(
        %info<mime-type>,
        $expect-with-flag,
        "file is $expect-with-flag with flag passed to from-filename",
    );
}

done-testing;
