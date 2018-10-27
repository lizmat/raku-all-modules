use Test;
use WebService::HazIP;

ok(1);

if (%*ENV<TRAVIS>) {
    diag "running on travis";
    my $ipObj = WebService::HazIP.new;
    say "My public IP address is: " ~ $ipObj.returnIP();
}

done-testing();
