use lib 'lib';
use Test;
use IO::MiddleMan;

constant $test-file-name = 'test-file' ~ rand;
END { unlink $test-file-name };

class TestGist { method gist { 'gist works!' } }

my $fh = $test-file-name.IO.open: :w;
my $mm = IO::MiddleMan.mute: $fh;

$mm.handle.say:   |<foo bar baz>, TestGist.new, 42;
$mm.handle.put:   |<foo bar baz>, 42;
$mm.handle.print: |<foo bar baz>, 42;
$mm.handle.print-nl;

my $out = "foobarbazgist works!42\n" # .say
            ~ "foobarbaz42\n"        # .put
            ~ "foobarbaz42"          # .print
            ~ "\n",                  # .print-nl

is $mm.Str, '', 'captured is empty'  ;
is $test-file-name.IO.slurp, $out,
    'filehandle output is there, despite the mute mode';

done-testing;
