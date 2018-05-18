use v6;
use Test;

plan 3;

my $server = %*ENV<DNS_TEST_HOST> // '8.8.8.8';

use Net::DNS;

my $resolver;
say '# using %*ENV<DNS_TEST_HOST> = '~$server if $server ne '8.8.8.8';
ok ($resolver = Net::DNS.new($server)), "Created a resolver";

my $response;
ok ($response = $resolver.lookup-mx("perl6.org")), "Lookup mx for perl6.org...";
ok ($response[0] eq "66.39.3.26"), "...Got a valid response!"; # this will probably need to change in the future
