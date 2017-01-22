use Test;
use Test::Scheduler;

{
    my $*SCHEDULER = Test::Scheduler.new();
    my $p = start { 2 ** 10 };
    is await($p), 2 ** 10, 'A single promise is scheduled immediately';
}

{
    my $*SCHEDULER = Test::Scheduler.new();
    my $c1 = Channel.new;
    my $c2 = Channel.new;
    my $p1 = start { $c1.send(2 ** 20); $c2.receive() + 5 }
    my $p2 = start { $c2.send($c1.receive() + 1) }
    is await($p1), 2 ** 20 + 6, 'Multiple concurrent promises are scheduled fine too';
}

done-testing;
