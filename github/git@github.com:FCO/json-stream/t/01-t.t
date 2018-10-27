use JSON::Stream;
use Test;

plan 93;

react {
    whenever json-stream Supply.from-list(['42',]), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value,  42;
    }

    whenever json-stream Supply.from-list(['3.14',]), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value,  3.14;
    }

    whenever json-stream Supply.from-list(['true',]), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value,  True;
    }

    whenever json-stream Supply.from-list(['"bla"',]), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value,  "bla";
    }

    whenever json-stream Supply.from-list(['["bla"]',]), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value.^name,  "Array";
        is $value.elems, 1;
    }

    whenever json-stream Supply.from-list(['["bla", "ble", "bli"]',]), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value.^name,  "Array";
        is $value.elems, 3;
    }

    whenever json-stream Supply.from-list(['["bla", 42, 3.14, true]',]), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value.^name,  "Array";
        is $value.elems, 4;
    }

    whenever json-stream Supply.from-list(['{"bla":"ble"}',]), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value.^name,  "Hash";
        is $value.elems, 1;
    }

    whenever json-stream Supply.from-list(['{"bla":"ble", "bli": "blo"}',]), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value.^name,  "Hash";
        is $value.elems, 2;
    }

    whenever json-stream Supply.from-list(['{"bla":42, "ble":[1,2], "bli":{"blo":"blu"}}',]), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value.^name,  "Hash";
        is $value.elems, 3;
    }

    whenever json-stream Supply.from-list(<[ { "bla" : "ble" } , { "bli" : "blo" } ]>), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value.^name,  "Array";
        is $value.elems, 2;
        is $value[0].^name, "Hash";
        is $value[0].elems, 1;
        is $value[1].^name, "Hash";
        is $value[1].elems, 1;
    }

    whenever json-stream Supply.from-list(<[ { "bla" : [1,2,3] } , { "ble" : {"bli": "blo", "blu": 42} } ]>), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value.^name,  "Array";
        is $value.elems, 2;
        is $value[0].^name, "Hash";
        is $value[0].elems, 1;
        is $value[0]<bla>.^name, "Array";
        is $value[0]<bla>.elems, 3;
        is $value[1].^name, "Hash";
        is $value[1].elems, 1;
        is $value[1]<ble>.^name, "Hash";
        is $value[1]<ble>.elems, 2;
    }

    whenever json-stream Supply.from-list(<[ { "bla" : [1,2,3] } , { "ble" : {"bli": "blo", "blu": 42} } ]>), [<$ 0>, <$ 1>] -> (:$key, :$value) {
        say "$key => $value.perl()";
        given $++ {
            when 0 {
                is $key,    '$.0';
                is $value.^name, "Hash";
                is $value.elems, 1;
                is $value<bla>.^name, "Array";
                is $value<bla>.elems, 3;
            }
            when 1 {
                is $key,    '$.1';
                is $value.^name, "Hash";
                is $value.elems, 1;
                is $value<ble>.^name, "Hash";
                is $value<ble>.elems, 2;
            }
        }
    }

    whenever json-stream Supply.from-list(<[ { "bla" : [1,2,3] } , { "ble" : {"bli": "blo", "blu": 42} } ]>), [['$', *],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        given $++ {
            when 0 {
                is $key,    '$.0';
                is $value.^name, "Hash";
                is $value.elems, 1;
                is $value<bla>.^name, "Array";
                is $value<bla>.elems, 3;
            }
            when 1 {
                is $key,    '$.1';
                is $value.^name, "Hash";
                is $value.elems, 1;
                is $value<ble>.^name, "Hash";
                is $value<ble>.elems, 2;
            }
        }
    }

    whenever json-stream Supply.from-list(<[ { "bla" : [1,2,3] } , { "bla" : {"bli": "blo", "blu": 42} } ]>), [['$', **, 'bla'],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        given $++ {
            when 0 {
                is $key,    '$.0.bla';
                is $value.^name, "Array";
                is $value.elems, 3;
            }
            when 1 {
                is $key,    '$.1.bla';
                is $value.^name, "Hash";
                is $value.elems, 2;
            }
        }
    }

    whenever json-stream Supply.from-list(<[ { "bla" : [1,2, {"blu" : 42}] } , { "ble" : {"bli": "blo", "blu": 13} } ]>), [['$', **, 'blu'],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        given $++ {
            when 0 {
                is $key,    '$.0.bla.2.blu';
                is $value, 42
            }
            when 1 {
                is $key,    '$.1.ble.blu';
                is $value, 13
            }
        }
    }

    whenever json-stream Supply.from-list(<{ " bla " : 42>), [['$', 'bla'],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$.bla';
        is $value, 42
    }

    whenever json-stream Supply.from-list(<{ " bla " : [ 1 , { "ble": 3.14>), [<$ bla 1 ble>,] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$.bla.1.ble';
        is $value, 3.14
    }

    whenever json-stream Supply.from-list(<" \" bla \" { [ \" ble \" ] } \" bli ">), [['$',],] -> (:$key, :$value) {
        say "$key => $value.perl()";
        is $key,    '$';
        is $value, "\"bla\"\{[\"ble\"]}\"bli";
    }
}

my Supplier $s .= new;
my Promise @p = Promise.new xx 10;

start react {
    whenever json-stream $s.Supply, [ [ **, ], ] -> (:$key, :$value) {
        say "$key -> $value";
        given $++ {
            when 0 {
                is $key,    '$.bla.0';
                is $value,  "test";
            }
            when 1 {
                is $key,    '$.bla.1.ble';
                is $value,  "bli";
            }
            when 2 {
                is $key,    '$.bla.1';
                is $value.^name, "Hash";
                is $value.elems, 1;
            }
            when 3 {
                is $key,    '$.bla';
                is $value.^name, "Array";
                is $value.elems, 2;
            }
            when 4 {
                is $key,    '$';
                is $value.^name, "Hash";
                is $value.elems, 1;
            }
        }
        @p.head.keep;
    }
}

sleep .1;
$s.emit: '{';
$s.emit: '"';
$s.emit: "bla";
$s.emit: '"';
$s.emit: ':';
$s.emit: '[';
$s.emit: '"test"';
await @p.shift;
$s.emit: ',';
$s.emit: '{';
$s.emit: '"';
$s.emit: "ble";
$s.emit: '"';
$s.emit: ':';
$s.emit: '"';
$s.emit: "bli";
$s.emit: '"';
await @p.shift;
$s.emit: '}';
await @p.shift;
$s.emit: ']';
await @p.shift;
$s.emit: '}';
await @p.shift;
$s.done;
