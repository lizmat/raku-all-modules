unit module BreakDancer;
use Shell::Command;

our $basedir = 'www';
our $ext = '.html';

multi gen($path, &code) is export {
    mkpath "$basedir/$path";
    given open("$basedir/$path/index$ext", :w) {
        .say: &code();
        .close;
    }
}

multi gen($path, @args, &code) is export {
    mkpath "$basedir/$path";
    for @args -> $a {
        my $p = "$basedir/$path/$a";
        mkpath $p;
        given open("$p/index$ext", :w) {
            .say: &code($a);
            .close;
        }
    }
}

multi gen($path, %args, &code) is export {
    mkpath "$basedir/$path";
    for %args.kv -> $k, $v {
        my $p = "$basedir/$path/$k";
        mkpath $p;
        given open("$p/index$ext", :w) {
            .say: &code($k, $v);
            .close;
        }
    }
}
