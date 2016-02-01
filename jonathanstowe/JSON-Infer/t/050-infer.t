#!perl6

use v6;
use Test;

use JSON::Infer;

use JSON::Name;
use JSON::Class;

my $obj;

lives-ok { $obj = JSON::Infer.new() }, "create a new JSON::Infer";
isa-ok($obj, JSON::Infer, "and it is the right sort of thing");

my $ret;

my $uri = 'http://api.mixcloud.com/spartacus/party-time/';
my $class-name = 'Mixcloud::Show';

lives-ok { $ret = $obj.infer(:$uri, :$class-name) }, "infer from mixcloud";
isa-ok($ret, JSON::Infer::Class, "and it does return a JSON::Infer::Class");

my $class-str;

lives-ok { $class-str = $ret.make-class() }, "make class";

lives-ok { EVAL $class-str }, "and make sure that it at least evals nicely";

my $type;

lives-ok { $type = ::($class-name) }, "and we have the type defined";

my $new-obj;
lives-ok { $new-obj = $type.new } , "and the type we defined actually can be constructed";

does-ok $new-obj, JSON::Class, "and has the role we want";

lives-ok {
    my $json = $obj.get($uri).decoded-content;
    my $show;
    lives-ok { $show = $type.from-json($json) }, "make object from the original json";
    isa-ok $show, $type, "and it is the right type";
    my $data = from-json($json);

    for $show.^attributes -> $attr {
        my $attr-name = do if $attr ~~ JSON::Name::NamedAttribute {
            $attr.name;
        }
        else {
            $attr.name.substr(2);
        }

        ok $data{$attr-name}:exists, "and the $attr-name is in the data";
        given $attr.type {
            when Positional {
                isa-ok $data{$attr-name}, Array, "array type attribute is array in data";
            }
            when Cool {
                is $show."{$attr.name.substr(2)}"(), $data{$attr-name}, "and the data matches";
            }
            default {
                isa-ok $data{$attr-name}, Hash, "object typed attribute is hash in data";
            }
        }
    }
}, "got back sensible data with from-json";



done-testing();

# vim: expandtab shiftwidth=4 ft=perl6
