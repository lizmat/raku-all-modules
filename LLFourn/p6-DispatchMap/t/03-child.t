use Test;
need DispatchMap;
plan 3;

my $map = DispatchMap.new(
    foo => (
        (Real,Str),"real str",
        (Int,Str),"int str",
    )
);

my $child = $map.make-child: foo => (
    (Int,Int) => "int int",
    (42,Str)  => "42 str",
);

is $child.get("foo",41,"str"),"int str","parent key still works in child";
is $child.get("foo",42,42),"int int", "1. child only key works";
is $child.get("foo",42,"foo"),"42 str","2. child only key works";
