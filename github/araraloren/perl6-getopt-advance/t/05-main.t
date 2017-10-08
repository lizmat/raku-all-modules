
use Test;
use Getopt::Advance;

plan 3;

my OptionSet $optset .= new;

$optset.insert-main(&sum1);
my $sumid = $optset.insert-main(&sum2);

getopt(
    <plus 1 2 3 4 5 6 7 8 9 10>,
    $optset
);

$optset.remove($sumid);

getopt(
    <multi 1 2 3 4 5 6 7 8 9 10>,
    $optset
);

sub sum1($optset, @args) {
    given @args.shift {
        when /plus/ {
            is (sum @args>>.value>>.Int), 55, "plus ok";
        }
        when /multi/ {
            is ([*] @args>>.value>>.Int), 3628800, "multi ok";
        }
    }
}

sub sum2(@args) {
    is @args>>.value, <plus 1 2 3 4 5 6 7 8 9 10>, "get non-option argument";
}
