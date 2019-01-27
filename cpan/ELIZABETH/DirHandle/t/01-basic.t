use v6.c;
use Test;

plan 1;

use DirHandle;

ok MY::<DirHandle>:exists, "is DirHandle imported by default?";

# vim: ft=perl6 expandtab sw=4
