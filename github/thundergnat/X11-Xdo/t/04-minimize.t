use Test;
use X11::libxdo;
my $xdo = Xdo.new;

my $id = $xdo.get-active-window;

loop {
    $xdo.minimize($id);
    $xdo.activate-window($id);
    sleep .5;
    $xdo.raise-window($id);
    sleep .25;
    last if $++ >= 2;
}

CATCH { default { fail } }

ok 1;
done-testing;
