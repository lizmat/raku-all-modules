use v6.c;
use Test;
use lib 'lib';
use Xmav::JSON;

plan 50;

isa-ok from-json("0"), Int;
isa-ok from-json("1"), Int;
isa-ok from-json("-1"), Int;
isa-ok from-json("0.0"), Rat;
isa-ok from-json("1.0"), Rat;
isa-ok from-json(".5"), Rat;
isa-ok from-json("0.5"), Rat;
isa-ok from-json("-1.1"), Rat;
isa-ok from-json("-.5"), Rat;
isa-ok from-json("-0.3"), Rat;

dies-ok { from-json("+1") }, "leading plus is a syntax error";
dies-ok { from-json("00.5") }, "leading 0s are syntax error";
dies-ok { from-json("+0.3") }, "leading plus is a syntax error";
dies-ok { from-json("03") },  "leading 0s are syntax error";
dies-ok { from-json("007") }, "leading 0s are syntax error";

isa-ok from-json("true"), Bool;
isa-ok from-json("false"), Bool;
isa-ok from-json("null"), Nil;

dies-ok { from-json("True") }, "case sensitive";
dies-ok { from-json("fAlse") }, "case sensitive";
dies-ok { from-json("nulL") }, "case sensitive";

isa-ok from-json('""'), Str;
isa-ok from-json('"isn\'t"'), Str;
isa-ok from-json('"\n"'), Str;
isa-ok from-json('"\f\uABCD"'), Str;

isa-ok from-json('""'), Str;
isa-ok from-json('"\""'), Str;

dies-ok { from-json('"\p"') }, "unknown escape";
dies-ok { from-json('"\u01X4"') }, "wrong unicode escape";
dies-ok { from-json("'not a string'") }, "only double quotes";
dies-ok { from-json('"\"') }, "missing closing \"";

isa-ok from-json("[]"), Array;
isa-ok from-json("[1]"), Array;
isa-ok from-json('["1"]'), Array;
isa-ok from-json('[{}]'), Array;
isa-ok from-json('[[]]'), Array;
isa-ok from-json('["",[],{},0,null,true,false]'), Array;

dies-ok { from-json('[1, 2,') }, "missing closing ]";
dies-ok { from-json('[1, 2') }, "missing closing ]";

isa-ok from-json('{}'), Hash;
isa-ok from-json('{"1":1}'), Hash;
isa-ok from-json('{"1":"1"}'), Hash;
isa-ok from-json('{"1":[ ]}'), Hash;
isa-ok from-json('{"1":{ }}'), Hash;
isa-ok from-json('{"1": true}'), Hash;
isa-ok from-json('{"1" :null}'), Hash;
isa-ok from-json('{"1":[],"a":{"b":2}}'), Hash;

dies-ok { from-json('{"1":null') }, 'missing closing }';
dies-ok { from-json('1, "2", 3') }, "bare arrays do not exist";
dies-ok { from-json('{1:1}') }, "keys must be string";


#done-testing;

