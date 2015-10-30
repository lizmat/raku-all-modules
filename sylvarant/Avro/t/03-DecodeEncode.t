use v6;
use Test;
use lib 'lib';
use Avro; 
use Avro::Auxiliary;

#======================================
# Test Setup
#======================================

my $encoder = Avro::BinaryEncoder.new();
my $decoder = Avro::BinaryDecoder.new();

my $enum_ex1 = Q<<
{ "type": "enum",
  "name": "Suit",
  "doc" : "A Card Enum",
  "symbols" : ["SPADES", "HEARTS", "DIAMONDS", "CLUBS"]
}>>;
my Avro::Enum $enum_schema = parse-schema($enum_ex1);

my $arr_ex1 = Q<<{ "type": "array", "items": "string" }>>;
my Avro::Array $array_schema = parse-schema($arr_ex1);

my $union_ex1 = Q<<[ "null" , "string", "int" ]>>;
my Avro::Union $union_schema = parse-schema($union_ex1);

my $fixed_ex1 = Q<<{"type": "fixed", "size": 8, "name": "md5"}>>;
my Avro::Fixed $fixed_schema = parse-schema($fixed_ex1);

my $map_ex1 = Q<<{ "type": "map", "values": "long" }>>;
my Avro::Map $map_schema = parse-schema($map_ex1);

my $map_ex2 =  Q<<{ "type": "map", "values": [ "null" , "string", "int" ] }>>;
my Avro::Map $map_schema2 = parse-schema($map_ex2);

my $record_ex1 = Q<<{ "type": "record", "name": "test", "fields" : [
	{"name": "a", "type": "long"},
  {"name": "b", "type": "string"}]}>>;
my Avro::Record $record_schema = parse-schema($record_ex1);

my $record_ex2 = Q<<{"namespace": "example.avro",
 "type": "record",
 "name": "User",
 "fields": [
     {"name": "name", "type": "string"},
     {"name": "favorite_number",  "type": ["int", "null"]},
     {"name": "favorite_color", "type": ["string", "null"]}
 ]
}>>;
my Avro::Record $record_schema2 = parse-schema($record_ex2);

my @data =  
  Avro::Boolean.new() => True, 
  Avro::Boolean.new() => False,
  Avro::Null.new()    => Any, 
  Avro::Integer.new() => 56, 
  Avro::Integer.new() => -668,
  Avro::Long.new()    => (1 +< 60),
  Avro::Bytes.new()   => "00FF", 
  Avro::String.new()  => "Hello Me",
  Avro::String.new()  => 'møp',
  Avro::Float.new()   => 2.5,
  Avro::Double.new()  => 8.375,
  $enum_schema        => "HEARTS",
  $array_schema       => [<cabana banana mango>],
  $array_schema       => [],
  $union_schema       => Any,
  $union_schema       => 5,
  $union_schema       => "string",
  $fixed_schema       => "12345678",
  $map_schema         => { "key1" => 12, "key2" => 23 },
  $map_schema2        => { "key1" => "key", "key2" => 23 },
  $record_schema      => { "a" => 27, b => "foo"},
  $record_schema2     => {"name" => "Alyssa", "favorite_number" =>  256, favorite_color => Any},
  $record_schema2     => {"name" => "Ben", "favorite_number" => 7, "favorite_color" => "red"};
  
plan +@data;


#======================================
# decode and encode
#======================================
for @data -> $item {
  my Blob $result = $encoder.encode($item.key,$item.value);
  my $res = $decoder.decode($result,$item.key);
  is-deeply $res, $item.value, to_str($item.value) ~ " -> correctly encoded & decoded as:"~ $item.key.type;
}


# vim: filetype=perl6
