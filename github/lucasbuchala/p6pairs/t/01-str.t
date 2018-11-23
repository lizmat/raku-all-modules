
use v6;
use Test;
use Duo;

my \p = Duo.new(1, 2);

is ~p, '1 => 2', 'prefix operator ~';

is p.Str,  '1 => 2', '.Str';
is p.gist, '1 => 2', '.gist';
is p.perl, 'duo(1, 2)', '.perl';

is Duo.gist, '(Duo)', 'type .gist';
is Duo.perl, 'Duo',   'type .perl';

done-testing;

# vim: ft=perl6
