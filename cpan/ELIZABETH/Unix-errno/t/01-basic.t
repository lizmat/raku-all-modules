use v6.c;
use Test;
use Unix::errno;

plan 4;

ok MY::<&errno>:exists,               'is errno imported?';
nok Unix::errno::<&errno>:exists,     'is errno NOT externally accessible?';
ok MY::<&set_errno>:exists,           'is set_errno imported?';
nok Unix::errno::<&set_errno>:exists, 'is set_errno NOT externally accessible?';

# vim: ft=perl6 expandtab sw=4
