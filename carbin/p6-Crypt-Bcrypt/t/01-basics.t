use v6;
use Test;
use Crypt::Bcrypt;

plan 7;

ok Crypt::Bcrypt.new(), 'module loads';
ok Crypt::Bcrypt.gensalt(), 'gensalt called';
ok Crypt::Bcrypt.hash(Str.new(), Crypt::Bcrypt.gensalt()), 'hash called';

my Crypt::Bcrypt $bc .= new();
ok $bc, 'object created';
ok $bc ~~ Crypt::Bcrypt, 'is Crypt::Bcrypt object';
ok $bc.gensalt(), 'gensalt called from object';
ok $bc.hash(Str.new(), $bc.gensalt()), 'hash called from object';

# vim: ft=perl6
