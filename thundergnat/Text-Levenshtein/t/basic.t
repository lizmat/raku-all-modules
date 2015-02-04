use Test;
plan 9;

use Text::Levenshtein;

is(distance("foo","four"),2,"Correct distance foo four");
is(distance("foo","foo"),0,"Correct distance foo foo");
is(distance("cow","cat"),2,"Correct distance cow cat");
is(distance("cat","moocow"),5,"Correct distance cat moocow");
is(distance("cat","cowmoo"),5,"Correct distance cat cowmoo");
is(distance("cow","moocow"),3,"Correct distance cow moocow");
is(distance("sebastian","sebastien"),1,"Correct distance sebastian sebastien");
is(distance("more","cowbell"),5,"Correct distance more cowbell");
my @foo = distance("foo","four","foo","bar");
my @bar = (2,0,3);
is(@foo,@bar,"Array test: Correct distances foo four foo bar");


