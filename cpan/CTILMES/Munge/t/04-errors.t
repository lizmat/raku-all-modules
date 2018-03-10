use Test;
use Test::When <extended>;

use Munge;

plan 5;

my $m = Munge.new;

throws-like { $m.decode('bad credential') }, X::Munge::Error, 'Bad Credential';

throws-like
{
    my $encoded = Munge.new(ttl => 1).encode;
    sleep 2;
    Munge.new.decode($encoded);
}, X::Munge::Error, 'Expired Credential';

throws-like
{
    my $encoded = Munge.new(ttl => 1).encode;
    Munge.new.decode($encoded);
    Munge.new.decode($encoded);
}, X::Munge::Error, 'Credential replayed';

throws-like
{
    my $encoded = Munge.new(uid-restriction => 0).encode;
    Munge.new.decode($encoded);
}, X::Munge::Error, 'Unauthorized credential - uid';

throws-like
{
    my $encoded = Munge.new(gid-restriction => 1).encode;
    Munge.new.decode($encoded);
}, X::Munge::Error, 'Unauthorized credential - gid';

done-testing;
