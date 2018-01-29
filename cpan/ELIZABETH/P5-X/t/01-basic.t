use v6.c;
use Test;
use P5-X;

my @exported = <r w x e d f l s z>.map: '&prefix:<-' ~ * ~ '>';

my @files = <r rw rwx rx>;
my @perms = <4  6   7  5>.map: (* ~ '00').parse-base(8);

plan @exported * 2 + @files * 6;

for @exported {
    ok defined(::($_)), "is $_ imported?";
    ok !defined(P5-X::{$_}), "is $_ externally NOT accessible?";
}

indir $?FILE.IO.parent, {
    LEAVE unlink(@files);  # cleanup

    for @files.kv -> $index, $file {
        spurt($file,$file);
        chmod(@perms[$index],$file);

        is (-e $file),              1, "is -e '$file' ok";
        is (-s $file),    $file.chars, "is -s '$file' ok";
        is (-e -s $file),           1, "is -e -s '$file' ok";
        is (-s -e $file), $file.chars, "is -s -e '$file' ok";

        is (-z $file),    "", "is -z '$file' ok";
        is (-f -z $file), "", "is -f -z '$file' ok";
    }

#    is (-f -z "nowhere"), "", "is -f -z 'nowhere' ok";
}

# vim: ft=perl6 expandtab sw=4
