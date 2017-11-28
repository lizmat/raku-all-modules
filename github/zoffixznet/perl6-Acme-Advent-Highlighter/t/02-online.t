use lib <lib>;
use Test::When <online>;

use Test::Notice;
use Test;
use Acme::Advent::Highlighter;

plan 1;

my $original-data = slurp $?FILE.IO.parent.child: '02-online.original.data';
my $expected-data = slurp $?FILE.IO.parent.child: '02-online.expected.data';

my $hl = Acme::Advent::Highlighter.new:
    token => '7042d1' # Github revokes tokens if it notices them in source
    ~ '47ec9'
    ~ 'f800ce'
    ~ '835935'
    ~ 'a24e3'
    ~ 'ee30e'
    ~ 'c5872c7';

notice 'Starting render of a document... This will take up to 2 minutes';
my $*ACME_ADVENT_HIGHLIGHTER_SILENCE_DEBUG = True;
is $hl.render($original-data, :wrap).&de-UUID-ify,
    $expected-data, 'rendered data';

sub de-UUID-ify {
    # scrupt UUIDs that'll differ between runs
    $^text.subst: :g, /
        <after 'advent-code-' | 'file-'>
        # e.g. dcb84306-350e-469b-8d0b-53e8724cc224
        <.xdigit>**8 '-' [<.xdigit>**4 '-']**3 <.xdigit>**12
    /, 'ID-REDACTED'
}
