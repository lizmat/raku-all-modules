use v6.c;
use Test;
use P5chdir;

plan 8;

my $basedir = $?FILE.IO.parent.parent;
my $home    = ~$basedir.child("bin");
my $logdir  = ~$basedir.child("lib");

%*ENV<HOME>   = $home;
%*ENV<LOGDIR> = $logdir;

is chdir, True, 'did a bare chdir() to HOME work';
is ~$*CWD, $home, 'did it actually go to the right directory';

%*ENV<HOME>:delete;
is chdir, True, 'did a bare chdir() to LOGDIR work';
is ~$*CWD, $logdir, 'did it actually go to the right directory';

%*ENV<LOGDIR>:delete;
is chdir, False, 'did a bare chdir() to nothing fail';
is ~$*CWD, $logdir, 'are we still at the right directory';

is chdir('..'), True, 'did a specific chdir work';
is ~$*CWD, ~$basedir, 'did we wind up in the right directory';

# vim: ft=perl6 expandtab sw=4
