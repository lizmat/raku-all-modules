
use v6;
use Test;
use Duo;

my \p = Duo.new(1, 2);

is-deeply p.Hash,                                 {1=>2},             'hash';
is-deeply p.Hash(:object),                       :{1=>2},             'hash :object';
is-deeply p.Hash(:named),                         {key=>1, value=>2}, 'hash :named';
is-deeply p.Hash(:named, :object),               :{key=>1, value=>2}, 'hash :named, :object';
is-deeply p.Hash(key=>'x', value=>'y'),           {x=>1, y=>2},       'hash kwargs';
is-deeply p.Hash(key=>'x', value=>'y', :object), :{x=>1, y=>2},       'hash kwargs :object';
is-deeply p.Hash('x', 'y'),                       {x=>1, y=>2},       'hash pos args';
is-deeply p.Hash('x', 'y', :object),             :{x=>1, y=>2},       'hash pos args :object';

done-testing;

# vim: ft=perl6
