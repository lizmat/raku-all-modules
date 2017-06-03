use lib <lib>;
use Testo;
use Proc::Q;

plan 2;

{
    my $before;
    my $after;
    react whenever proc-q
        ^3 .map({ $*EXECUTABLE, '-e', 'sleep 1'}),
        :1batch
    {
        once $before = now;
        $after = now;
    }
    is ($after - $before).Int, 2..4, '1 batch';
}

{
    my $before;
    my $after;
    react whenever proc-q
        ^3 .map({ $*EXECUTABLE, '-e', 'sleep 1'}),
        :3batch
    {
        once $before = now;
        $after = now;
    }
    is ($after - $before).Int, 0..1, '3 batch';
}
