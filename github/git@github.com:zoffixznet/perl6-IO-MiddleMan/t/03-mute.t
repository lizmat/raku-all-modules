use lib 'lib';
use Test;
use IO::MiddleMan;

constant $test-file-name = 'test-file' ~ rand;
END { unlink $test-file-name };

class TestGist { method gist { 'gist works!' } }

my $fh = $test-file-name.IO.open: :w;
my $mm = IO::MiddleMan.mute: $fh;

$fh.say:   |<foo bar baz>, TestGist.new, 42;
$fh.put:   |<foo bar baz>, 42;
$fh.print: |<foo bar baz>, 42;
$fh.print-nl;

is $mm.Str,                  '', 'captured output is empty'  ;
is $test-file-name.IO.slurp, '', 'filehandle output is empty';

done-testing;
