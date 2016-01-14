use lib 'lib';
use Test;
use IO::MiddleMan;

constant $test-file-name = 'test-file' ~ rand;
END { unlink $test-file-name };

class TestGist { method gist { 'gist works!' } }
my $out = "foobarbazgist works!42\n" # .say
            ~ "foobarbaz42\n"        # .put
            ~ "foobarbaz42"          # .print
            ~ "\n",                  # .print-nl


my $fh = $test-file-name.IO.open: :w;
my $mm = IO::MiddleMan.hijack: $fh;

subtest {
    perform-write $fh;
    is $mm.Str,                  $out x 1, 'captured output looks correct';
    is $test-file-name.IO.slurp, $out x 0, 'filehandle output looks correct';
}, 'first hijack';

subtest {
    $mm.mode = 'capture';
    perform-write $fh;
    is $mm.Str,                  $out x 2, 'captured output looks correct';
    is $test-file-name.IO.slurp, $out x 1, 'filehandle output looks correct';
}, 'capture';

subtest {
    $mm.mode = 'mute';
    perform-write $fh;
    is $mm.Str,                  $out x 2, 'captured output looks correct';
    is $test-file-name.IO.slurp, $out x 1, 'filehandle output looks correct';
}, 'mute';

subtest {
    $mm.mode = 'normal';
    perform-write $fh;
    is $mm.Str,                  $out x 2, 'captured output looks correct';
    is $test-file-name.IO.slurp, $out x 2, 'filehandle output looks correct';
}, 'normal';

subtest {
    $mm.mode = 'hijack';
    perform-write $fh;
    is $mm.Str,                  $out x 3, 'captured output looks correct';
    is $test-file-name.IO.slurp, $out x 2, 'filehandle output looks correct';
}, 'second hijack';

done-testing;

sub perform-write (IO::Handle $fh) {
    $fh.say:   |<foo bar baz>, TestGist.new, 42;
    $fh.put:   |<foo bar baz>, 42;
    $fh.print: |<foo bar baz>, 42;
    $fh.print-nl;
}