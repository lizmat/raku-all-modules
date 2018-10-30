use v6;
use lib 'lib';
use File::Path::Resolve;
use Test;

plan(3);

subtest(qq{'scripts/script.lua', 't/data/conky/conkyrc'}, {
    my Str:D $script = 'scripts/script.lua';
    my Str:D $conkyrc = 't/data/conky/conkyrc';
    my IO::Path:D $path = File::Path::Resolve.relative($script, $conkyrc);
    my IO::Path $expected .= new('t/data/conky/scripts/script.lua');
    is($path, $expected.IO.resolve);
});

subtest(qq{'../tint2/tint2rc', 't/data/conky/conkyrc'}, {
    my Str:D $tint2rc = '../tint2/tint2rc';
    my Str:D $conkyrc = 't/data/conky/conkyrc';
    my IO::Path:D $path = File::Path::Resolve.relative($tint2rc, $conkyrc);
    my IO::Path $expected .= new('t/data/tint2/tint2rc');
    is($path, $expected.IO.resolve);
});

subtest(qq{'~/Downloads/data/script.lua', 't/data/conky/conkyrc'}, {
    my Str:D $script = '~/Downloads/data/script.lua';
    my Str:D $conkyrc = 't/data/conky/conkyrc';
    my IO::Path:D $path = File::Path::Resolve.relative($script, $conkyrc);
    my IO::Path $expected .=
        new(sprintf(Q{%s/Downloads/data/script.lua}, $*HOME));
    is($path, $expected);
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
