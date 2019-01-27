use Test;
use X11::libxdo;
my $xdo = Xdo.new;

my $active = $xdo.get-active-window;

my $command = $*VM.config<os> eq 'darwin' ?? 'open' !! 'xdg-open';

my $location = IO::Path.new($?FILE).dirname;

shell "$command $location/test.html" or die 'Could not open test page';
sleep 1.5;

my $match = 'Test Page';

say "Window IDs matching string $match:";
say my $w = $xdo.search(:name($match))<ID>;

sleep .25;

my $para = qq:to/END/;
{"\r\n\r\n"}
Slow Text:
{"\r\n\r\n"}
This is a paragraph of text. It is kind of boring, but I needed something in
 here and figured this is (marginally) more interesting than Hello World!
 multiple times.
{"\r\n\r\n"}
Sorry, can not automatically close this window (or tab, as the case may be)
 safely.
{"\r\n\r\n"}
Please close it manually when testing is done, but only AFTER testing is done.
{"\r\n\r\n"}
Probably should avoid touching the mouse and keyboard completely until then if possible.
{"\r\n\r\n"}
Thanks.
{"\r\n\r\n"}
Meanwhile; enjoy the show 🙂. Note: if nothing happens for more than 5 seconds
 or so, you may need to cancel the install, open a web browser window, and try
 the install again. IPC is a little flaky sometimes.
{"\r\n\r\n"}
END

if $w {
    say "Window name: ", $xdo.get-window-name( $w );
    $xdo.send-sequence($w, 'Tab');
    $xdo.type($w, "Fast Text:\r\n\r\n" ~ ("Hello World! " x 6), 1000);
    $xdo.type($w, $para, 80000);
    $xdo.activate-window($w);
}

sleep 2;

CATCH { default { note $_; fail } }

ok 1;
done-testing;
