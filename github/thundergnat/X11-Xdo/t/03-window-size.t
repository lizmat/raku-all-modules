use Test;
use X11::libxdo;
my $xdo = Xdo.new;


my $id = $xdo.get-active-window;

my ($w,  $h ) = $xdo.get-window-size( $id );
my ($wx, $wy) = $xdo.get-window-location( $id );
my ($dw, $dh) = $xdo.get-desktop-dimensions( 0 );

$xdo.move-window( $id, 150, 150 );

my $dx = $dw - 300;
my $dy = $dh - 300;

$xdo.set-window-size( $id, $dx, $dy, 0 );

sleep .25;

my $s = -1;

loop {
    $dx += $s * ($dw / 200).ceiling;
    $dy += $s * ($dh / 200).ceiling;
    $xdo.set-window-size( $id, $dx, $dy, 0 );
    $xdo.activate-window($id);
    sleep .005;
    $s *= -1 if $dy < 200;
    last if $dx >= $dw;
}

sleep .25;

$xdo.set-window-size( $id, $w, $h, 0 );
$xdo.move-window( $id, $wx, $wy );
$xdo.activate-window($id);

CATCH { default { fail } }

ok 1;
done-testing;
