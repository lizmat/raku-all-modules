use Test;
use JSON::Unmarshal;

plan 18;

class Dog {
    has Str $.name;
    has Str $.race;
    has Int $.age;
}

my $json = q/
[
    {
        "name": "Roger",
        "race": "corgi",
        "age": 4
    },
    {
        "name": "Panda",
        "race": "wolfish",
        "age": 13
    }
]
/;


my @dogs = unmarshal($json, Array[Dog]);
ok @dogs ~~ Positional;
isa-ok @dogs[0], Dog;
is @dogs[0].name, "Roger";
is @dogs[0].race, "corgi";
is @dogs[0].age, 4;

isa-ok @dogs[1], Dog;
is @dogs[1].name, "Panda";
is @dogs[1].race, "wolfish";
is @dogs[1].age, 13;


my $json-two = q/
{
    "good dog":
        {
            "name": "Roger",
            "race": "corgi",
            "age": 4
        },
    "also a good dog":
        {
            "name": "Panda",
            "race": "wolfish",
            "age": 13
        }
}
/;

my %dogs = unmarshal($json-two, Hash[Dog]);
ok %dogs ~~ Associative;
isa-ok %dogs{'good dog'}, Dog;
is %dogs{'good dog'}.name, "Roger";
is %dogs{'good dog'}.race, "corgi";
is %dogs{'good dog'}.age, 4;

isa-ok %dogs{'also a good dog'}, Dog;
is %dogs{'also a good dog'}.name, "Panda";
is %dogs{'also a good dog'}.race, "wolfish";
is %dogs{'also a good dog'}.age, 13;
