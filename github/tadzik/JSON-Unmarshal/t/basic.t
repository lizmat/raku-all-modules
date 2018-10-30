use Test;
use JSON::Unmarshal;

class Dog {
    has Str $.name;
    has Str $.race;
    has Int $.age;
}

class Person {
    has Str $.name;
    has Int $.age;
    has Dog @.dogs;
    has Str %.contact;
}

my $json = q/
{
    "name" : "John Brown",
    "age"  : 17,
    "contact" : {
       "email" : "jb@example.com",
       "phone" : "12345678"
    },
    "dogs"  : [{
        "name" : "Roger",
        "race" : "corgi",
        "age"  : 4
    },
    {
        "name" : "Panda",
        "race" : "wolfish",
        "age"  : 13
    }]
}
/;

my $p = unmarshal($json, Person);

isa-ok $p, Person;
is $p.name, "John Brown";
is $p.age, 17;
is $p.contact<email>, 'jb@example.com';
is $p.contact<phone>, "12345678";
is $p.dogs.elems, 2;
is $p.dogs[0].name, 'Roger';
is $p.dogs[0].race, 'corgi';
is $p.dogs[0].age, 4;

is $p.dogs[1].name, 'Panda';
is $p.dogs[1].race, 'wolfish';
is $p.dogs[1].age, 13;

# Tests for the un-typed cases
class ArrayTest {
   has @.array;
}

$json = q/
{
   "array" : [ "one", 1, true, 42.3 ]
}
/;

lives-ok { $p = unmarshal($json, ArrayTest) }, "unmarshal object with un-shaped array attribute";

is $p.array.elems, 4;

is $p.array[0], "one";
is $p.array[1], 1;
is $p.array[2], True;
is $p.array[3], 42.3;

class HashTest {
   has %.hash;
}

$json = q/
{
   "hash" : { "string" : "one", "int" : 1, "bool" : true, "rat" : 42.3 }
}
/;

lives-ok { $p = unmarshal($json, HashTest) }, "unmarshal object with un-shaped hash attribute";

is $p.hash.keys.elems, 4;
is $p.hash<string>, "one";
is $p.hash<int>, 1;
is $p.hash<bool>, True;
is $p.hash<rat>, 42.3;

done-testing;
# vim: expandtab shiftwidth=4 ft=perl
