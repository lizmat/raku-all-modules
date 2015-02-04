use v6;
use Test;

plan 6;

my $server = %*ENV<DNS_TEST_HOST> // '8.8.8.8';

use Net::DNS;

ok True, "Module loaded";

my $resolver;
say '# using %*ENV<DNS_TEST_HOST> = '~$server if $server ne '8.8.8.8';
ok ($resolver = Net::DNS.new($server)), "Created a resolver";

my $response;
ok ($response = $resolver.lookup("A", "perl6.org")), "Lookup A record for perl6.org...";
ok ($response[0] eq "193.200.132.142"), "...Got a valid response!"; # this will probably need to change in the future

ok ($response = $resolver.lookup("A", "perl6.org.")), "Lookup A record for perl6.org. (with trailing dot)...";
ok ($response[0] eq "193.200.132.142"), "...Got a valid response!"; # this will probably need to change in the future
