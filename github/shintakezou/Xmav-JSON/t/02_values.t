use v6.c;
use Test;
use lib 'lib';
use Xmav::JSON;

plan 34;

is from-json("0"), 0, "0";
is from-json("1"), 1, "1";
is from-json("-1"), -1, "-1";
is from-json("0.0"), 0, "0.0";
is from-json("1.0"), 1, "1.0";
is from-json(".5"), .5, "0.5";
is from-json("0.5"), .5, "0.5";
is from-json("-1.1"), -1.1, "-1.1";
is from-json("-.5"), -.5, "-.5";
is from-json("-0.3"), -.3, "-.3";

is from-json("true"), True, "True";
is from-json("false"), False, "False";
is from-json("null"), Nil, "Nil";

is from-json('""'), "", "void string";
is from-json('"isn\'t"'), "isn\'t", "escape '";
is from-json('"\n"'), "\n", "newline";
is from-json('"\f\uABCD"'), "\f\x[ABCD]", "formfeed and unicode";
is from-json('"\""'), "\"", "escape \"";

is from-json("[]"), [], "void array";

is-deeply from-json("[1]"), [1,], "[1]";
is-deeply from-json('["1"]'), ["1"], '["1"]';
is-deeply from-json('[{}]'), [{},], '[{}]';
is-deeply from-json('[[]]'), [[],], '[[]]';
is-deeply from-json('["",[],{},0,null,true,false]'), ["", [], {}, 0, Nil, True, False], '["",[],{},0,null,true,false]';
 
is-deeply from-json('{}'), {}, '{}';
is-deeply from-json('{"1":1}'), {"1"=>1}, '{"1":1}';
is-deeply from-json('{"1":"1"}'), {"1"=>"1"}, '{"1":"1"}';
is-deeply from-json('{"1":[ ]}'), {"1"=>[]}, '{"1":[ ]}';
is-deeply from-json('{"1":[ ]}'), {"1"=>Array.new}, '{"1":[ ]}';
is-deeply from-json('{"1":{ }}'), {"1"=>{}}, '{"1":{ }}';
is-deeply from-json('{"1":{ }}'), {"1"=>Hash.new}, '{"1":{ }}';
is-deeply from-json('{"1": true}'), {"1" => True}, '{"1": true}';
is-deeply from-json('{"1" :null}'), {"1"=>Nil}, '{"1" :null}';
is-deeply from-json('{"1":[],"a":{"b":2}}'), {"1"=>[],"a"=>{"b"=>2}}, '{"1":[],"a":{"b":2}}';


#done-testing;

