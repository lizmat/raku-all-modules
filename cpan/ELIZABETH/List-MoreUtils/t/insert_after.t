use v6.c;

use List::MoreUtils <insert_after>;
use Test;

plan 6;

my @longer = <This is a longer list>;

my @list = <This is a list>;
insert_after( { $_ eq "a" }, "longer" => @list);
is-deeply @list, @longer, "longer positional Pair";

@list = <This is a list>;
insert_after( { $_ eq "a" }, longer => @list);
is-deeply @list, @longer, "longer named parameter";

@list = <This is a list>;
insert_after( { $_ eq "a" }, "longer", @list);
is-deeply @list, @longer, "longer just positionals";

insert_after { 0 }, "bla" => @list;
is-deeply @list, @longer, "insert at 0";

insert_after { $_ eq "list" }, "!" => @list;
is-deeply @list, [|@longer,"!"], "insert after last";

@list = 'This','is', Nil, 'list';
insert_after { not defined($_) }, "longer" => @list;
@longer[2] = Nil;
is-deeply @list, @longer, "insert after type object";

# vim: ft=perl6 expandtab sw=4
