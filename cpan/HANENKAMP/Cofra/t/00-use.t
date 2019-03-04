use v6;
use Test;

my @files = 'lib'.IO;
while @files.shift -> $file {
    next if $file.basename eq '.precomp';

    if $file.d {
        @files.append: $file.dir;
    }

    elsif $file.f && $file.basename ~~ / ".pm6" $/ {
        my $module-name = "$file"
            .subst(/ ".pm6" $/, '')
            .subst(/^ "lib/" /, '')
            .subst(/ "/" /, '::', :g);

        use-ok $module-name;
    }
}

done-testing;
