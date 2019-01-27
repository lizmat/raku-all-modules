use Test;
use X11::libxdo;
my $xdo = Xdo.new;

my $id = $xdo.get-active-window;

say my $this = $xdo.get-desktop-for-window($id);

say my $desktops = $xdo.get-number-of-desktops();

$xdo.set-current-desktop((^$desktops).pick);
$xdo.get-active-window;

for ^$desktops {
    $xdo.set-current-desktop($_);
    $xdo.get-active-window;
    sleep 1;
}

$xdo.set-current-desktop($this);
$xdo.activate-window($id);

CATCH { default { fail } }

ok 1;
done-testing;
