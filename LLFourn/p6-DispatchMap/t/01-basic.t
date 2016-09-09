use DispatchMap;
use Test;

plan 15;


my @init := ((Real,Str),"foo",
             (Int,Str),"baz",
             (Str,Real),"bar",
            );
my @init-pairs = @init.map: { $^k => $^v };

my $map := DispatchMap.new(|@init);
is-deeply $map.keys, DispatchMap.new(@init).keys,"SAR works with constructor";
is-deeply $map.keys, DispatchMap.new(@init-pairs).keys,"Pair arguments work";
is-deeply $map.keys,( (Real,Str),(Int,Str),(Str,Real) ),".keys";
is-deeply $map.values,("foo","baz","bar"),".values";




is-deeply $map.list,@init,".list";

is $map.get(Real,Str),"foo","1. correct";
is $map.get(Str,Real),"bar","2. correct";
is $map.get(Int,Str),"baz","3. correct";
is $map.get(Int,Int),Nil,"key that doesn't exist returns Nil";

is $map.get-all(Int,Str).elems,2,"get-all returns both matching";
is $map.get-all(Int,Str)[0],"baz","get-all[0] is correct";
is $map.get-all(Int,Str)[1],"foo","get-all[1] is correct";

ok $map.exists(Real,Str),"exists works with something that exists";
nok $map.exists(Int,Int),"exists works with something that doesn't exists";

$map.append((Cool,Perl),"squirtle");
is $map.get(Cool,Perl),"squirtle",".set works";
