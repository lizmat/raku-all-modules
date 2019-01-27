use Test;
use X11::libxdo;
my $xdo = Xdo.new;

my $active = $xdo.get-active-window;

sleep .25;

$xdo.type($active, "OK: Should be safe to close now.\r\n\r\n", 50000);

sleep 2;

CATCH { default { note $_; fail } }

ok 1;
done-testing;
