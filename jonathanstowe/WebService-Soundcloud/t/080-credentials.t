#!perl6

use v6;
use lib 'lib';
use Test;



use WebService::Soundcloud;

my $username = %*ENV{'SC_USERNAME'};
my $password = %*ENV{'SC_PASSWORD'};

if (defined $username && defined $password)
{
    plan 7;
}
else
{
    plan 7;
    skip-rest 'No $SC_USERNAME or $SC_PASSWORD defined';
    exit(0);
}



my $client-id = 'a1afc8eb1cbb96b787a5fb5232a8b4f6';
my $client-secret = 'd78d89f377b28d9f2a2692a14a55c501';

my %args = ( 
               scope         => 'non-expiring',
               username      => $username,
               password      => $password
            ) ;

ok(my $sc = WebService::Soundcloud.new( :$client-id, :$client-secret,|%args),"new object with credentials");

ok(my $token = $sc.get-access-token(), "get access token - no code needed");
ok(my $me = $sc.get-object('/me'), "get_object - /me");
ok($me{'permalink'}, "and the data has something in it");
ok(my $tracks = $sc.get-list('/me/tracks'), 'get_list - "/me/tracks"');
ok(?$tracks.elems, "and we got some tracks");
is($tracks.elems, $me{'track_count'}, "and the same as the number on the me");

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
