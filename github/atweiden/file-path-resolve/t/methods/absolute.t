use v6;
use lib 'lib';
use File::Path::Resolve;
use Test;

plan(3);

subtest(Q{'~'}, {
    my Str:D $tilde = '~';
    my IO::Path:D $path = File::Path::Resolve.absolute($tilde);
    my IO::Path:D $expected = $*HOME;
    is($path, $expected);
});

subtest(Q{'~/'}, {
    my Str:D $tilde = '~/';
    my IO::Path:D $path = File::Path::Resolve.absolute($tilde);
    my IO::Path:D $expected = $*HOME;
    is($path, $expected);
});

subtest(Q{'~/.config/conky/conkyrc'}, {
    my Str:D $conkyrc = '~/.config/conky/conkyrc';
    my IO::Path:D $path = File::Path::Resolve.absolute($conkyrc);
    my IO::Path $expected .= new(sprintf(Q{%s/.config/conky/conkyrc}, $*HOME));
    is($path, $expected);
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
