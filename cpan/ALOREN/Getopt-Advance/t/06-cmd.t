
use Test;
use Getopt::Advance;
use Getopt::Advance::Exception;

plan 7;

my OptionSet $optset .= new;

$optset.insert-cmd("plus");

supply {
    whenever $optset.Supply($optset.insert-cmd("multi")) {
        ok True, 'call the cmd callback';
    }
}.tap;

&main(|getopt(<plus 1 2 3 4 5 6 7 8 9 10>, $optset,));

$optset.reset-cmd("plus");

&main(|getopt(<multi 1 2 3 4 5 6 7 8 9 10>, $optset,));

$optset.reset-cmd("multi");

$optset.insert-cmd("join", sub __main($, @noa) {
    my $sep = @noa.shift.value;
    is (join $sep, @noa>>.value>>.Str), "english|chinese|japanese", "join ok";
});

getopt(<join | english chinese japanese>, $optset);

sub main($ret) {
    my @noa = $ret.noa;
    @noa.shift;

    if $optset.get-cmd("plus").success {
        is (sum @noa>>.value>>.Int), 55, "plus ok";
    } elsif $optset.get-cmd("multi").success {
        is ([*] @noa>>.value>>.Int), 3628800, "multi ok";
    }
}

my OptionSet $osa .= new;

$osa.insert-main(sub ($os, @_) { $os });
$osa.insert-pos(
    "want-digit",
    0,
    sub ($_) { False }
);

my OptionSet $osb = $osa.clone();
my OptionSet $osc = $osa.clone();

my $a = $osa.insert-cmd("a");
my $b = $osb.insert-cmd("b");
my $c = $osc.insert-cmd("c");

for < a b c > -> $cmd {
    is &getopt(<< $cmd >>.List, $osa, $osb, $osc).optionset, {a => $osa, b => $osb, c => $osc}{$cmd}, "match cmd ok";
    $osa.reset-cmd($a);
    $osb.reset-cmd($b);
    $osc.reset-cmd($c);
}
