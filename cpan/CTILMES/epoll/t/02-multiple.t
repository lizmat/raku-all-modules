use Test;
use epoll;

plan 10;

my $epoll = epoll.new(maxevents => 5);

ok $epoll, 'Create default epoll';

my @procs = do for ^5 { run 'cat', :in, :out };
my @fds = @procs.map({ .out.native-descriptor });

for @fds
{
    $epoll.add($_, :in);
}

my @events = $epoll.wait(:0timeout);

is @events, [], "No events ready";

@procs[0].in.say: "test\n";
@procs[2].in.say: "more testing\n";
@procs[4].in.say: "yet more testing\n";

sleep .1;  # Make sure all three writes get through before wait

@events = $epoll.wait;

is @events.elems, 3, "3 events ready from blocking wait";

for ^3
{
    ok @events[$_].fd == any(@fds[0,2,4]), "correct file descriptor $_";
    ok @events[$_].in, "$_ readable";
}

for 0,2,4
{
    @procs[$_].in.close;
    @procs[$_].out.slurp(:close);
}

@events = $epoll.wait(:0timeout);

is @events, [], "No events";

done-testing;
