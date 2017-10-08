use lib 'lib';
use Test;
use IO::MiddleMan;

constant $test-file-name = 'test-file' ~ rand;
END { unlink $test-file-name };

class TestGist { method gist { 'gist works!' } }

my $fh = $test-file-name.IO.open: :w;
my $mm = IO::MiddleMan.capture: $fh;

$fh.say:   |<foo bar baz>, TestGist.new, 42;
$fh.put:   |<foo bar baz>, 42;
$fh.print: |<foo bar baz>, 42;
$fh.print-nl;

my $out = "foobarbazgist works!42\n" # .say
            ~ "foobarbaz42\n"        # .put
            ~ "foobarbaz42"          # .print
            ~ "\n",                  # .print-nl

is $mm.Str,                  $out, 'captured output looks correct'  ;
is $test-file-name.IO.slurp, $out, 'filehandle output looks correct';

done-testing;
