
use Test;
use Getopt::Advance;

plan 6;

my OptionSet $optset .= new;

$optset.insert-main(&sum1);

my $sumid = $optset.insert-main(&sum2);

my $id = $optset.insert-main();

my $tap = $optset.Supply($id).tap(-> $v {
    my ($os, $main, @v) := @$v;

    is $os, $optset, 'get the optset from main(' ~ $id ~ ')';
    is @v, <plus 1 2 3 4 5 6 7 8 9 10>, '    and get all the NOA'; 
});

getopt(
    <plus 1 2 3 4 5 6 7 8 9 10>,
    $optset
);
$tap.close;
$optset.remove($sumid);
$optset.insert-main(&sum3);

getopt(
    <multi 1 2 3 4 5 6 7 8 9 10>,
    $optset
);

sub sum1($optset, @args) {
    given @args[0] {
        when /plus/ {
            is (sum @args[1..*]>>.value>>.Int), 55, "plus ok";
        }
        when /multi/ {
            is ([*] @args[1..*]>>.value>>.Int), 3628800, "multi ok";
        }
    }
}

sub sum2(@args) {
    is @args>>.value, <plus 1 2 3 4 5 6 7 8 9 10>, "get non-option argument";
}

sub sum3() {
	is 1, 1, "call argument less main";
}
