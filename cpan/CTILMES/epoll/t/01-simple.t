use Test;
use epoll;

plan 6;

my $epoll = epoll.new;

ok $epoll, 'Create default epoll';

my $proc = run 'cat', :in, :out;

my $fd = $proc.out.native-descriptor;

$epoll.add($fd, :in);

my @events = $epoll.wait(:0timeout);

is @events, [], "No events ready";

$proc.in.say: "test\n";

@events = $epoll.wait;

is @events.elems, 1, "1 event ready from blocking wait";

is @events[0].fd, $fd, "correct file descriptor";

ok @events[0].in, "readable";

$proc.in.close;

my $out = $proc.out.slurp(:close);

@events = $epoll.wait(:0timeout);

is @events, [], "No events";

done-testing;

