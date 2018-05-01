use v6.c;
use Test;
use Unix::errno;

plan 6;

is errno.^name, 'errno', 'is errno of the right class';
is +(set_errno(2)), 2, 'did we get the Int after setting';
is errno.^name, 'errno', 'is errno still of the right class';

is +errno,     2,                                       'did we get the Int';
is errno.Str,  'No such file or directory',             'did we get the Str';
is errno.gist, 'No such file or directory (errno = 2)', 'did we get the gist';

# vim: ft=perl6 expandtab sw=4
