use v6.c;
use Test;
use Algorithm::DawkinsWeasel;

my $weasel = Algorithm::DawkinsWeasel.new;

ok $weasel.isa('Algorithm::DawkinsWeasel'), 'is a Algorithm::DawkinsWeasel';

is $weasel.target-phrase, 'METHINKS IT IS LIKE A WEASEL', 'target-phrase';
is $weasel.mutation-threshold, 0.05, 'mutation-threshold';
is $weasel.copies, 100, 'copies';

for $weasel.evolution {
    diag join '', (.count.fmt('%04d '), .current-phrase, ' [', .hi-score, ']');
}

is $weasel.current-phrase, 'METHINKS IT IS LIKE A WEASEL', 'target reached';

done-testing;
