use v6;
use Test;
use ENIGMA::Machine::Plugboard;

# testing bad settings
{

    dies-ok {
        Plugboard.from-key-sheet('AB CD EF GH IJ KL MN OP QR ST UV');
    }, "testing with too many pairs - Heer/Luftwaffe";

    dies-ok {
        Plugboard.from-key-sheet('18/26 17/4 21/6 3/16 19/14 22/7 8/1 12/25 5/9 10/15 2/20');
    }, "testing with too many pairs - Kriegsmarine";

    dies-ok {
        Plugboard.from-key-sheet('AB CD EF GH IJ KL MN OF QR ST');
    }, "testing with duplicate pairs";

    dies-ok {
        Plugboard.from-key-sheet('AB CD EF GH IJ KL MN FP QR ST');
    }, "testing with duplicate pairs";

    dies-ok {
        Plugboard.from-key-sheet('18/26 17/4 21/6 3/16 19/14 22/3 8/1 12/25');
    }, "testing with duplicate pairs - Kriegsmarine";

    dies-ok {
        Plugboard.from-key-sheet('A2 CD EF GH IJ KL MN FP QR ST');
    }, "testing with invalid pairs";

    dies-ok {
        Plugboard.from-key-sheet('A2 CD EF *H IJ KL MN FP QR ST');
    }, "testing with invalid pairs";

    dies-ok {
        Plugboard.from-key-sheet('ABCD EF GHIJKL MN FP QR ST');
    }, "testing with badly formatted pairs - Kriegsmarine";

    dies-ok {
        Plugboard.from-key-sheet('A-B EF MN FP');
    }, "testing with badly separated pairs";

    dies-ok {
        Plugboard.from-key-sheet('A');
    }, "testing with no complete pairs";

    dies-ok {
        Plugboard.from-key-sheet('9');
    }, "testing with no complete pairs";

    dies-ok {
        Plugboard.from-key-sheet('1*/26 17/4 21/6 3/16 19/14 22/3 8/1 12/25');
    }, "testing with badly formatted pairs - Kriegsmarine";

    dies-ok {
        Plugboard.from-key-sheet('18/26 17/4 2A/6 3/16 19/14 22/3 8/1 12/25');
    }, "testing with badly formatted pairs - Kriegsmarine";

    dies-ok {
        Plugboard.from-key-sheet('100/2');
    }, "testing with pair exceeding boundary - Kriegsmarine";

    dies-ok {
        Plugboard.from-key-sheet('100');
    }, "testing with no complete pairs";

    # dies-ok {
    #     Plugboard.from-key-sheet('T/C');
    # }, "testing with badly formatted pairs - Kriegsmarine";

}


{
    say "Testing valid settings";
    my $p;
    lives-ok { $p = Plugboard.new() },
    "testing with empty new constructor";

    lives-ok { $p = Plugboard.new(setting => ()) }, 
    "testing with empty new constructor - named parameter version -- from-key-sheet constructor";

    lives-ok { $p = Plugboard.new(setting => []) },
    "testing with empty new constructor - named parameter version -- from-key-sheet constructor";

    lives-ok { $p = Plugboard.from-key-sheet('AB CD EF GH IJ KL MN OP QR ST') },
    "testing valid Heer/Luftwaffe wiring -- from-key-sheet constructor";

    lives-ok { $p = Plugboard.from-key-sheet('CD EF GH IJ KL MN OP QR ST') },
    "testing valid Heer/Luftwaffe wiring -- from-key-sheet constructor";

    lives-ok { $p = Plugboard.from-key-sheet('EF GH IJ KL MN OP QR ST') },
    "testing valid Heer/Luftwaffe wiring -- from-key-sheet constructor";

    lives-ok { $p = Plugboard.from-key-sheet('18/26 17/4 21/6 3/16 19/14 22/7 8/1 12/25') },
    "testing valid Kriegsmarine wiring -- from-key-sheet constructor";

    lives-ok { $p = Plugboard.from-key-sheet('18/26 17/4') },
    "testing valid Kriegsmarine wiring -- from-key-sheet constructor";

    lives-ok { $p = Plugboard.from-key-sheet() },
    "testing with empty from-key-method constructor -- from-key-sheet constructor";

    lives-ok { $p = Plugboard.from-key-sheet('') },
    "testing with empty string -- from-key-sheet constructor";
}

{
    my $p = Plugboard.new();
    for ^26 -> $n {
        is $n, $p.signal($n), "testing default wiring for signal $n";
    }
}

# Test 1
{
    my @settings = 'AB CD EF GH IJ KL MN OP QR ST',
                   '1/2 3/4 5/6 7/8 9/10 11/12 13/14 15/16 17/18 19/20';

    for @settings -> $s {
        my $p = Plugboard.from-key-sheet($s);

        for ^26 -> $n {
            if $n < 20 {
                if $n %% 2 { is $p.signal($n), $n + 1, "testing wiring (Test 1)"; }
                else { is $p.signal($n), $n - 1, "testing wiring (Test 1)"; }
            }
            else {
                is $n, $p.signal($n), "testing wiring (Test 1)";
            }
        }
    }

}


# Test 2
{
    my $stecker='AV BS CG DL FU HZ IN KM OW RX';

    my %wiring;
    my @pairs = $stecker.split(/\s+/);

    for @pairs -> $pair {
        my ($m, $n) = ord($pair.comb.head) - ord('A'), ord($pair.comb.tail) - ord('A');

        %wiring{$m} = $n;
        %wiring{$n} = $m;
    }

    my $p = Plugboard.from-key-sheet($stecker);
    for ^26 -> $n {
        if %wiring{$n}:exists {
            is $p.signal($n).Str, %wiring{$n}.Str, "testing wiring (Test 2)";
        }
        else {
            is $p.signal($n).Str, $n.Str, "testing wiring (Test 2)";
        }
    }
}

# Testing string
{
    my $stecker = 'AB CD EF GH IJ KL MN OP QR ST';
    my $p = Plugboard.from-key-sheet($stecker);

    is $stecker, $p.army-str(), "testing army formatted string";

    my $navy = '1/2 3/4 5/6 7/8 9/10 11/12 13/14 15/16 17/18 19/20';
    is $navy, $p.navy-str(), "testing navy formatted string";
}


done-testing;
