use lib 'lib';
use Test;
use NASA::APOD;

my %expected =
    copyright => "Arnar Kristjansson",
    date => "2016-4-4",
    explanation => "Is this the real world?  Or is it just fantasy?"
        ~ "  The truth started with a dream -- a dream that the spectacular"
        ~ " Seljarlandsfoss waterfall in southern Iceland could be"
        ~ " photographed with a backdrop of an aurora-filled sky.  Soon"
        ~ " after a promising space weather report, the visionary"
        ~ " astrophotographer and his partner sprang into action.  After"
        ~ " arriving, capturing an image of the background sky, complete with"
        ~ " a cool green aurora, turned out to be the easy part.  The hard"
        ~ " part was capturing the waterfall itself, for one reason because"
        ~ " mist kept fogging the lens!  Easy come, easy go -- it took about"
        ~ " 100 times where someone had to go back to the camera -- on a cold"
        ~ " night and over slippery rocks -- to see how the last exposure"
        ~ " turned out, wipe the lens, and reset the camera for the next try."
        ~ " Later, the best images of land and sky were digitally combined."
        ~ "  Visible in the sky, even well behind the aurora, are numerous"
        ~ " stars of the northern sky. The resulting title -- given by the"
        ~ " astrophotographer -- was influenced by a dream-like quality of the"
        ~ " resulting image, possibly combined with the knowledge that some"
        ~ " things really mattered in this effort to make a dream come true.",
    hdurl => "http://apod.nasa.gov/apod/image/1604/"
        ~ "AuroraFalls_Kristjansson_1920.jpg",
    media_type => "image",
    service_version => "v1",
    title => "Lucid Dreaming",
    url => "http://apod.nasa.gov/apod/image/1604/"
        ~ "AuroraFalls_Kristjansson_960.jpg";

my NASA::APOD $apod .= new: key => 't/key'.IO.lines[0];

subtest {
    my $res = $apod.apod: '2016-04-04';
    is $res.WHAT, Hash, 'Response is a hash';
    is-deeply $res, %expected, 'Response looks correct';
}, 'testing .apod with Str argument';

subtest {
    my $res = $apod.apod: Date.new: '2016-04-04';
    is $res.WHAT, Hash, 'Response is a hash';
    is-deeply $res, %expected, 'Response looks correct';
}, 'testing .apod with Dateish argument';

subtest {
    my $res = $apod.apod;
    is $res.WHAT, Hash,             'Response is a hash';
    ok $res<date>.chars,            'date is there';
    ok $res<explanation>.chars,     'explanation is there';
    ok $res<hdurl>.chars,           'hdurl is there';
    ok $res<url>.chars,             'url is there';
    ok $res<title>.chars,           'title is there';
    is $res<media_type>, 'image',   'media_type is correct';
    is $res<service_version>, 'v1', 'service_version is correct';
}, 'testing .apod with no arguments';

is $apod.Str.WHAT,  Str, 'calling .Str without a date works';
is $apod.gist.WHAT, Str, 'calling .gist without a date works';

my $*NASA-TESTING-TODAY = '2016-04-04';
is $apod.Str,  "%expected<title>: %expected<hdurl>", '.Str is sane';
is $apod.gist, "%expected<title>: %expected<url>",   '.gist is sane';

done-testing;
