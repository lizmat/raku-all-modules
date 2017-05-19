use Test;
use API::USNavalObservatory;

ok(1);

if (%*ENV<TRAVIS>) {
    diag "Running test on travis";
    my $webAgent = API::USNavalObservatory.new;
    say $webAgent.WHAT;
}
done-testing();
