use v6;
use Test;
use ENIGMA::Machine::Rotor;
use ENIGMA::Machine::Factory;
use ENIGMA::Machine::Data;

my $WIRING = 'EKMFLGDQVZNTOWYHXUSPAIBRCJ';


# test for bad wiring
{
    dies-ok {
        Rotor.new(:model('I'), :turnover('Q'), :ring-setting('A'), :wiring(''))
    }, "testing with empty wiring";

    dies-ok {
        Rotor.new(:model('I'), :turnover('Q'), :ring-setting('A'), :wiring('ABC'))
    }, "testing with wirinng containing few letters (less than 26)";

    dies-ok {
        Rotor.new(:model('I'), :turnover('Q'), :ring-setting('A'), :wiring('123'))
    }, "testing with wirings containing numbers (less than 26)";

    my $w = (flat '!'..'@', '['..'`', '{'..'~').pick(26).join;
    dies-ok {
        Rotor.new(:model('I'), :turnover('Q'), :ring-setting('A'), :wiring => ($w))
    }, "testing with 26-characters wiring of random punctuation symbols";

    $w = ('ABCD' x 7).split('').pick(26).join;
    dies-ok {
        Rotor.new(:model('I'), :turnover('Q'), :ring-setting('A'), :wiring($w))
    }, "testing with 26-characters wiring of repeated letters";
}


# test bad ring setting
{
    dies-ok {
        Rotor.new(:model('I'), :wiring($WIRING), :turnover('Q'), :ring-setting(-1))
    }, "testing with ring setting out of range 0-25 (negative)";

    dies-ok {
        Rotor.new(:model('I'), :wiring($WIRING), :turnover('Q'), :ring-setting(26))
    }, "testing with ring setting out of range 0-25 (positive)";

    dies-ok {
        Rotor.new(:model('I'), :wiring($WIRING), :turnover('Q'), :ring-setting(Nil))
    }, "testing with Nil ring setting";

    dies-ok {
        Rotor.new(:model('I'), :wiring($WIRING), :turnover('Q'), :ring-setting('A'))
    }, "testing with alphabetical ring setting";
}


# testing with turnover
{
    dies-ok { 
        Rotor.new(:model('I'), :wiring($WIRING), :ring-setting('A'), :turnover('0'))
    }, "testing with stringy zero";

    dies-ok { 
        Rotor.new(:model('I'), :wiring($WIRING), :ring-setting('A'), :turnover('A0'))
    }, "testing with letter-number mix";

    dies-ok { 
        Rotor.new(:model('I'), :wiring($WIRING), :ring-setting('A'), :turnover(1))
    }, "testing with number";


    dies-ok { 
        Rotor.new(:model('I'), :wiring($WIRING), :ring-setting('A'), :turnover(['A', '%', '14']))
    }, "testing with array";

    dies-ok { 
        Rotor.new(:model('I'), :wiring($WIRING), 
                  :ring-setting('A'), :turnover(%(on => 1, off => 0)))
    }, "testin with hash";
}


# test for display value
{
    my $rotor = Rotor.new(
        :model('I'), 
        :wiring($WIRING), 
        :ring-setting(0),
        :turnover('Q'),
    );
    for 'A'..'Z' -> $value {
        $rotor.set-display($value);
        is($value, $rotor.get-display, "testing rotor's display value");
    }
}



{

    sub rotate( $wiring, $n ) {
        my @letters = $wiring.comb(/\w/);
        my $offset  = $n % 26;

        return flat (@letters.splice(*-$offset), @letters);
    }

    for ^26 -> $r {
        my $rotor =  Rotor.new(:model('I'), :wiring($WIRING), :ring-setting($r));
    
        for ('A'..'Z').kv -> $key, $value {
            $rotor.set-display($value);
    
            my @wiring = $WIRING.comb();
            @wiring = rotate(@wiring, $r - $key);
    
            for 0..25 -> $i {
                my $output =  $rotor.signal-in($i);
                my $expected = ( ord(@wiring[$i]) - 'A'.ord + $r - $key ) % 26;
                cmp-ok $output, &[==], $expected, 
                'resulting signal in and expected output are the same';
    
                $output = $rotor.signal-out($expected);
                cmp-ok $output, &[==], $i,
                'resulting signal out and expected output are the same';
            }
        }
    }

}



# Testing notches: For every rotor simulated, ensure the notch setting is
# the same regardless of the ring setting.
{
    my @rotor_names = %ROTORS.keys();

    for @rotor_names -> $rotor_name {
        my $notches = %ROTORS{$rotor_name}{'turnover'};
        next unless $notches.defined;

        for ^26 -> $r {
            my $rotor = create-rotor($rotor_name, $r);
            $rotor.set-display('A');

            for ^26 -> $n {
                my $over_notch = $rotor.get-display (elem) ($notches.comb(/\w/));
                #is $rotor.notch-over-pawl, $over_notch, "testing notch setting";
                $rotor.rotate();
            }

        }

    }

}

# Testing rotate method
{
    for ^26 -> $r {
        my $rotor1 = Rotor.new(:model('X'), :wiring($WIRING), :ring-setting($r));
        my $rotor2 = Rotor.new(:model('Y'), :wiring($WIRING), :ring-setting($r));

        $rotor2.set-display('A');

        for ('A'..'Z').kv -> $key, $value {
            $rotor2.set-display($value);
            is $rotor1.get-display, $rotor2.get-display, "testing rotation";
            $rotor1.rotate();
        }
    }
}

done-testing;
