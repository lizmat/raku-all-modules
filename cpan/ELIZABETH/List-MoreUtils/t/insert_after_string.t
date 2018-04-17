use v6.c;

use List::MoreUtils <insert_after_string>;
use Test;

plan 5;

my @longer = <This is a longer list>;

my @list = <This is a list>;
insert_after_string( "a", "longer" => @list);
is-deeply @list, @longer, "longer positional Pair";

@list = <This is a list>;
insert_after_string( "a", longer => @list);
is-deeply @list, @longer, "longer named parameter";

@list = <This is a list>;
insert_after_string( "a", "longer", @list);
is-deeply @list, @longer, "longer just positionals";

@list = Nil,|<This is a list>;
insert_after_string "a", "longer", @list;
is-deeply @list, [Nil,|@longer], "longer with undefined values";

@list = "This\0", "is\0", "a\0", "list\0";
insert_after_string "a\0", "longer\0", @list;
is-deeply @list, ["This\0", "is\0", "a\0", "longer\0", "list\0"],
  "longer with null bytes in strings";

# vim: ft=perl6 expandtab sw=4
