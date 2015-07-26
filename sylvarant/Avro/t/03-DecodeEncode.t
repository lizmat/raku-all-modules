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

my @schemas =  Avro::Boolean.new(), Avro::Boolean.new() , Avro::Null.new(), Avro::Integer.new(), 
  Avro::Integer.new(), Avro::Long.new(), Avro::Bytes.new(), Avro::String.new(), Avro::String.new(),
  Avro::Float.new(),Avro::Double.new(),$enum_schema, $array_schema, $array_schema, $union_schema,$union_schema,
  $union_schema,$fixed_schema, $map_schema,$map_schema2,$record_schema, $record_schema2, $record_schema2;
my @datas =  True, False, Any, 56, -668, (1 +< 60),"00FF","Hello Me", 'møp', 2.5, 8.375, "HEARTS",
  [<cabana banana mango>], [], Any, 5, "string","12345678", { "key1" => 12, "key2" => 23 },
  { "key1" => "key", "key2" => 23 }, { "a" => 27, b => "foo"}, {"name" => "Alyssa", "favorite_number" =>  256, favorite_color => Any},
  {"name" => "Ben", "favorite_number" => 7, "favorite_color" => "red"};
my @zipped = (@schemas Z @datas);


plan +@schemas;


#======================================
# decode and encode
#======================================

for @zipped -> $schema, $data {
  my Blob $result = $encoder.encode($schema,$data);
  my $res = $decoder.decode($result,$schema);
  is-deeply $res, $data, to_str($data) ~ " -> correctly encoded & decoded as:"~ $schema.type;
}


# vim: filetype=perl6
