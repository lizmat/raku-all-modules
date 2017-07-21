

use Test;
use Getopt::Advance;

plan 3;

my OptionSet $optset .= new;

$optset.insert-cmd("plus");
$optset.insert-cmd("multi");

&main(|getopt(<plus 1 2 3 4 5 6 7 8 9 10>, $optset,));

$optset.reset-cmd("plus");

&main(|getopt(<multi 1 2 3 4 5 6 7 8 9 10>, $optset,));

$optset.reset-cmd("multi");

$optset.insert-cmd("join", sub __main($, @noa) {
    @noa.shift;
    my $sep = @noa.shift.value;
    is (join $sep, @noa>>.value>>.Str), "english|chinese|japanese", "join ok";
});

getopt(<join | english chinese japanese>, $optset);

sub main($, @noa) {
    @noa.shift;

    if $optset.get-cmd("plus").success {
        is (sum @noa>>.value>>.Int), 55, "plus ok";
    } elsif $optset.get-cmd("multi").success {
        is ([*] @noa>>.value>>.Int), 3628800, "multi ok";
    }
}
