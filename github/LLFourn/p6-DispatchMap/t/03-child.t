use Test;
need DispatchMap;
plan 3;



{
    my $parent = DispatchMap.new(
        foo => (
            (Real,Str),"real str",
            (Int,Str),"int str",
        )
    ).compose;

    my $child = DispatchMap.new.add-parent($parent).append(foo => (
        (Int,Int) => "int int",
        (42,Str)  => "42 str",
    )).compose;

    is $child.get("foo",41,"str"),"int str","add-parent key still works in child";
    is $child.get("foo",42,42),"int int", "add-parent 1. child only key works";
    is $child.get("foo",42,"foo"),"42 str","add-parent 2. child only key works";
}
