use DispatchMap;
use Test;

plan 16;

{
    my $map = DispatchMap.new(
       things => (
           (Int) =>  "an Int!",
           (subset :: of Int:D where * > 5) => "Wow, an Int greater than 5",
           ("foo")           => "A literal foo",
           (Str)             => "one string",
           (Stringy)         => "something stringy",
           (Str,Str)         => "two strings",
           (Any:U) => { "Not sure what this is: {.gist}" },
        )).compose;


    is $map.get('things',2),'an Int!';
    is $map.get('things',6),'Wow, an Int greater than 5';
    is $map.get('things',"foo"),'A literal foo';
    $map.append(things => ((π) => "pi",(τ) => "tau")).compose;
    is $map.get('things',τ),"tau";
    ok $map.get-all('things',"foo") ~~ ("A literal foo","one string","something stringy");
    is $map.get('things',"foo","bar"),'two strings';
    ok $map.get('things',Perl),Block;
    is $map.dispatch('things',Perl),"Not sure what this is: {Perl.gist}";
}

{
    my $map = DispatchMap.new(
        abstract-join => (
            (Str:D,Str:D) => { $^a ~ $^b },
            (Iterable:D,Iterable:D) => { |$^a,|$^b },
            (Numeric:D,Numeric:D) => { $^a + $^b }
        )).compose;

    is $map.dispatch('abstract-join',"foo","bar"),"foobar";
    is-deeply $map.dispatch('abstract-join',<one two>,<three four>),<one two three four>;
    is $map.dispatch('abstract-join',1,2),3;
}

{
    my $map = DispatchMap.new(
        things => (
            (Str:D) => -> $str { "a string: $str" },
            (Int:D) => -> $int { "an int: $int" },
            (42)    => -> $int { "a special int" }
        )).compose;
    is $map.dispatch('things',"lorem"), "a string: lorem";
    is $map.dispatch('things',42),"a special int";
}

{
    my $parent = DispatchMap.new(
        number-types => (
            (Numeric) => "A number",
            (Int) => "An int",
        )
    ).compose;

    my $child = DispatchMap.new
    .add-parent($parent)
    .append(number-types => ( (π) => "pi" ))
    .compose;

    is $child.get('number-types',3.14), 'A number';
    is $parent.get('number-types',π), 'A number';
    is $child.get('number-types',π), 'pi';
}
