use DispatchMap;
use Test;
plan 11;

{
    my $parent = DispatchMap.new(
        foo => (
            (Real,Str) => "real str",
            (Int,Str) => "int str",
        ),
        bar => ((Int,Int) => "int int"),
        baz => (),
    );

    $parent.ns-meta('foo')= "foo meta";
    $parent.compose;
    $parent.ns-meta('bar') = "bar meta";
    $parent.ns-meta('baz') = "baz meta";

    is $parent.get("foo",1,"str"),"int str","dispatcher still works after ns-meta";
    is $parent.ns-meta('foo'),"foo meta","ns-meta can be stored before compose";
    is $parent.ns-meta('bar'),"bar meta","ns-meta can be stored after compose";

    nok $parent.ns-meta('BLERG'),"there shouldn't be a ns-meta for a candidate that doesn't exist";
    nok $parent.namespaces.first('BLERG'),"calling .ns-meta shouldn't create a namespace";

    my $child =
    DispatchMap.new()
    .add-parent($parent)
    .compose;

    is $child.ns-meta('foo'),"foo meta","child's ns-meta is the same";

    my $override = DispatchMap.new()
    .add-parent($child)
    .override(
        foo => (
            (Int,Int) => "int int",
            (42,Str)  => "42 str",
        ),
        baz => (),
    );
    $override.ns-meta('baz') = "changed baz";
    $override.compose;

    is $override.get('bar',1,2),"int int","bar didn't get overridden";
    isnt $override.ns-meta('foo'),"foo meta",'override cancels parent ns-meta';
    is $override.ns-meta('baz'),"changed baz",'can still change ns-meta on children';
    is $parent.ns-meta('baz'),"baz meta","modifying overridden ns-meta doesn't affect parent";
    is $override.get('foo',1,"bar"),Nil,"override cancels parent candidates";
}
