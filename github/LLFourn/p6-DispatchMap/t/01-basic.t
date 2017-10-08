use DispatchMap;
use Test;

plan 17;


my %init = (
    things => (
        (Real,Str),"foo",
        (Int,Str),"baz",
        (Str,Real),"bar",
    ),
    foo => (
        (Real,Str),"foo",
    )
);

my %init-pairs = things => %init<things>.map: { $^k => $^v };
my $map := DispatchMap.new(|%init).compose;
is-deeply $map.keys('things'), DispatchMap.new(|%init).compose.keys('things'),"SAR works with constructor";
is-deeply $map.keys('things'), DispatchMap.new(|%init-pairs).compose.keys('things'),"Pair arguments work";
is-deeply $map.keys('things'),( (Real,Str),(Int,Str),(Str,Real) ),".keys";
is-deeply $map.values('things'),("foo","baz","bar"),".values";
is-deeply $map.list('things'),  %init<things>,".list";

is $map.get('things',Real,Str),"foo","1. correct";
is $map.get('things',Str,Real),"bar","2. correct";
is $map.get('things',Int,Str),"baz","3. correct";
is $map.get('things',Int,Int),Nil,"key that doesn't exist returns Nil";

is $map.get-all('things',Int,Str).elems,2,"get-all returns both matching";
is $map.get-all('things',Int,Str)[0],"baz","get-all[0] is correct";
is $map.get-all('things',Int,Str)[1],"foo","get-all[1] is correct";

ok $map.exists('things',Real,Str),"exists works with something that exists";
nok $map.exists('things',Int,Int),"exists works with something that doesn't exists";

$map.append(things => ((Cool,Perl) => "squirtle") ).compose;
is $map.get('things',Cool,Perl),"squirtle",".append works";

is $map.get('not-exist',(Int,Str)),Nil,"namespace that does't exist returns Nil";
ok $map.namespaces ~~ <things foo>.Set,".namespaces works";
