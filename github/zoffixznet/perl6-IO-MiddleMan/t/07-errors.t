use lib 'lib';
use Test;
use IO::MiddleMan;

throws-like { IO::MiddleMan.new },
    Exception, '.new cannot be called',
    message => 'Cannot instantiate with .new. Please use one of '
        ~ '.hijack, .capture, .mute, or .normal methods.';

my $fh = IO::Handle.new;
my $mm = IO::MiddleMan.hijack: $fh;

throws-like { $mm.mode = 'not right' },
    Exception, 'incorrect mode must fail',
    message => /'Type check failed in assignment to $!mode; expected IO::MiddleMan::ValidMode but got Str'/;

done-testing;
