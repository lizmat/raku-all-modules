
use v6;
use Test;
use Informative;

plan *;

if %*ENV<DISPLAY> or $*DISTRO.is-win {
    my $p;
    lives-ok {$p = inform(:timer(2))}
    lives-ok {$p.show('A string')}
    isa-ok $p, Informative::Informing, 'is the correct type';
}

done-testing;
