use v6;
use Test;
use lib 'lib';
use Avro; 
use JSON::Tiny;

plan 33;

#======================================
# Test :: Primitive Types
#======================================

# reject incorrect type
my $parsed = 0;
try {
  parse-schema(to-json("nonsense")); 
  $parsed = 1; 
}
nok  $parsed,"Nonsense is not a Primitive";

# single string
my Avro::Schema $primitive = parse-schema("string"); 
ok ($primitive ~~ Avro::Primitive),"String identified as Primitive";
is-deeply $primitive.to_json(),'{ "type" : "string" }',"To JSON works";

# object
my $obj_ex = Q<<{"type" : "boolean"}>>;
$primitive = parse-schema($obj_ex); 
ok ($primitive ~~ Avro::Primitive),"Boolean object identified as Primitive";
is-deeply $primitive.to_json(),'{ "type" : "boolean" }',"To JSON works";


#======================================
# Test :: Record Types
#======================================

my $avro_ex = Q<<{"namespace": "example.avro",
 "type": "record",
 "name": "User",
 "fields": [
     {"name": "name", "type": "string"},
     {"name": "favorite_number",  "type": ["int", "null"]},
     {"name": "favorite_color", "type": ["string", "null"]}
 ]
}>>;

my $avro_ex2 = Q<<{
 "type": "record",
 "name": "User",
 "fields": [
     {"name": "name", "type": "string"}
 ]
}>>;

my $avro_exp2 = Q<<{
 "type": "record",
 "name": "User",
 "fields": [
     {"name": "name", "type": { "type" : "string" }}
 ]
}>>;

my Avro::Schema $record = parse-schema($avro_ex);
ok ($record ~~ Avro::Record),"Record identified";
is $record.name(),"User","Correct name";
is $record.namespace(),"example.avro","Correct namespace";
is $record.fullname(),"example.avro.User","Correct fullname";

my Avro::Schema $record2 = parse-schema($avro_ex2);
is $record2.fullname(),"User","Correct fullname";
is $record2.namespace(),"","Correct namespace";
is-deeply from-json($record2.to_json()),from-json($avro_exp2), "To JSON works";

# test field defaults
my $default_ex1 = Q<<{
 "type": "record",
 "name": "User",
 "fields": [
     {"name": "name", "type": "string", "default" : 5 }
 ]
}>>;

$parsed = 0;
{
  parse-schema($default_ex1);
  CATCH {
    when X::Avro::Field {  $parsed = 1; }
    default { say $_.message();  $parsed = 0; }
  }
}
ok $parsed, "Faulty default refused";

my $default_ex2 = Q<<{
 "type": "record",
 "name": "User",
 "fields": [
     {"name": "name", "type": "double", "default" : 1.1}
 ]
}>>;

$parsed = 0;
try {
  parse-schema($default_ex2);
  $parsed = 1;
}
ok $parsed, "Correct default accepted";

# test faulty names
my $name_ex1 = Q<<{
 "type": "record",
 "name": "2User",
 "fields": [
     {"name": "name", "type": "string", "default" : "hello" }
 ]
}>>;
$parsed = 0;
{
  parse-schema($name_ex1);
  CATCH {
    when X::Avro::FaultyName {  $parsed = 1; }
    default { say $_.message();  $parsed = 0; }
  }
}
nok $parsed, "Incorrect name rejected";

my $name_ex2 = Q<<{
 "namespace" : "Avro.Me",
 "type": "record",
 "name": "Hello.User",
 "fields": [
     {"name": "name", "type": "string", "default" : "hello" } ]}>>;
my Avro::Record $nr = parse-schema($name_ex2);
is $nr.namespace(),"Hello","Fullname name space identified";


#======================================
# Test :: Array Types
#======================================

my $arr_ex1 = Q<<{ "type": "array", "items": "string" }>>;
my $arr_exp1 = Q<<{ "type": "array", "items": {"type" :"string"} }>>;
my Avro::Schema $array = parse-schema($arr_ex1);
ok ($array ~~ Avro::Array),"Array identified";
is-deeply from-json($array.to_json()),from-json($arr_exp1),"To JSON works";


#======================================
# Test :: Map Types
#======================================

my $map_ex1 = Q<<{ "type": "map", "values": "long" }>>;
my $map_exp1 = Q<<{ "type": "map", "values": {"type" :"long"} }>>;
my Avro::Schema $map = parse-schema($map_ex1);
ok ($map ~~ Avro::Map),"Map identified";
is-deeply from-json($map.to_json()),from-json($map_exp1),"To JSON works";


#======================================
# Test :: Union Types
#======================================

my $union_ex1 = Q<<[ "null" , "string", "int" ]>>;
my $union_exp1 = Q<<[ { "type" : "null" }, { "type" : "string" }, {"type" : "int" }]>>;
my Avro::Schema $union = parse-schema($union_ex1);
ok ($union ~~ Avro::Union),"Union identified";
is-deeply from-json($union.to_json()),from-json($union_exp1),"To JSON works";

# test double primitives
my $union_ex2 = Q<<[ "string" , "long", "null", "string" ]>>;
$parsed = 0;
try {
  $union = parse-schema($union_ex2);
  $parsed = 1;
}
nok  $parsed,"Unions cannot include duplicate primitive types";

# test no unions
my $union_ex3 = Q<<[ "string" , "long", [ "null" , "string" ] ,"null", "string" ]>>;
$parsed = 0;
try {
  $union = parse-schema($union_ex3);
  $parsed = 1;
}
nok  $parsed,"Unions cannot include other unions";

# test no duplicate complex types
my $union_ex4 = Q<<[ "string" , "long", { "type" : "array" , "items" : "string" }, "null" , 
{ "type" : "map", "items" : "int" },
{ "type" : "array", "items" : "int" } ]>>;
$parsed = 0;
try {
  $union = parse-schema($union_ex4);
  $parsed = 1;
}
nok  $parsed,"Unions cannot include duplicate array";

# test no duplicate named records
my $union_ex5 = '[' ~ $avro_ex ~ "," ~ $avro_ex2 ~ ']';
$union = parse-schema($union_ex5);
ok ($union ~~ Avro::Union),"Double Records work";
my $union_ex6 = '[' ~ $avro_ex ~ "," ~ $avro_ex ~ ']';
$parsed = 0;
try {
  $union = parse-schema($union_ex6);
  $parsed = 1;
}
nok  $parsed,"Unions cannot include records of the same name";


#======================================
# Test :: Enum Types
#======================================

my $enum_ex1 = Q<<
{ "type": "enum",
  "name": "Suit",
  "doc" : "A Card Enum",
  "symbols" : ["SPADES", "HEARTS", "DIAMONDS", "CLUBS"]
}>>;

my $enum_exp1 = Q<<
{ "type": "enum",
  "name": "Suit",
  "doc" : "A Card Enum",
  "symbols" : ["SPADES", "HEARTS", "DIAMONDS", "CLUBS"]
}>>;

my $enum_ex2 = Q<<
{ "type": "enum",
  "name": "Suit"}>>;

my Avro::Schema $enum = parse-schema($enum_ex1);
ok ($enum ~~ Avro::Enum),"Enum identified";
is-deeply from-json($enum.to_json()),from-json($enum_exp1),"To JSON works";

$parsed = 0;
try {
  $union = parse-schema($enum_ex2);
  $parsed = 1;
}
nok  $parsed,"Enums must define Symbols";


#======================================
# Test :: Fixed Types
#======================================

my $fixed_ex1 = Q<<{"type": "fixed", "size": 16, "name": "md5"}>>;
my $fixed_ex2 = Q<<{"type": "fixed", "name": "md6"}>>;

my Avro::Schema $fixed = parse-schema($fixed_ex1);
ok ($fixed ~~ Avro::Fixed),"Fixed identified";
is-deeply from-json($fixed.to_json()),from-json($fixed_ex1),"To JSON works";

$parsed = 0;
try {
  $union = parse-schema($fixed_ex2);
  $parsed = 1;
}
nok $parsed,"Fixed must define size";

# vim: filetype=perl6
