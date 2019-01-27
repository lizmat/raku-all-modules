use v6.c;
use Test;

use Env;

# make sure we have an ENV<USER>
BEGIN %*ENV<USER> //= ~$*USER;

# make sure we have an ENV<PATH>
BEGIN my $sep = $*DISTRO.path-sep;
BEGIN %*ENV<PATH> //= <foo bar baz>.join($sep);

my $thePATH = %*ENV<PATH>;
my @thePATH = $thePATH.split($sep);

use Env <$USER @PATH>;

plan 15;

is $USER, ~$*USER,   'did we find the user';
is ($USER = 42), 42, 'did the change propagate';
is %*ENV<USER>,  42, 'did we change inside %*ENV also';

is (%*ENV<USER> = 666), 666, 'did the change propagate';
is $USER, 666, 'did the change propagate inside the variable also';

is ($USER = Nil), Nil, 'did the change to Nil propagate';
is $USER, Nil,          'did we actually reset $USER';
nok %*ENV<USER>:exists, 'did we actually remove USER from %*ENV';

is-deeply @PATH, @thePATH, 'did we get a correctly split PATH';

@PATH.push("foobar");
is-deeply @PATH, [|@thePATH,"foobar"], 'did we keep a correctly split PATH';
is %*ENV<PATH>, $thePATH~$sep~"foobar", 'did we keep a correctly joined PATH';

is (%*ENV<PATH> = $thePATH), $thePATH, 'did change to PATH propagate';
is-deeply @PATH, @thePATH, 'did we get a correctly restored PATH';

is (%*ENV<PATH> = Nil), Nil, 'did the change to the environment propagate';
nok %*ENV<PATH>:exists, 'did we actually remove PATH from %*ENV';

# vim: ft=perl6 expandtab sw=4
