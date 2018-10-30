use v6;
use Test;
use lib 'lib';
use Avro; 

plan 4;

#======================================
# Issue #6 from Github
#======================================

my $avro_ex = Q<<
{ "namespace": "foo.comr",
  "type": "record",
  "name": "Company",
  "fields": [
      {"name": "source", "type": ["string","null"]},
      {"name": "name", "type": ["string"]},
      {"name": "customer_number",  "type": ["string", "null"]},
      {"name": "customer_type", "type": ["string", "null"]},
  {"name": "address",  "type":
   [ "null",
     { "type": "record",   "name": "Address",
       "fields": [
           {"name": "street1", "type": ["string","null"]},
           {"name": "street2", "type": ["string","null"]},
           {"name": "street3", "type": ["string","null"]},
           {"name": "street4", "type": ["string","null"]},
           {"name": "city", "type": ["string","null"]},
           {"name": "state", "type": ["string","null"]},
           {"name": "zipcode", "type": ["string","null"]},
           {"name": "country", "type": ["string","null"]}
       ]
     }
   ]
  }
  ]
}
>>;

my $path = "datafile";
my Avro::Schema $schema = parse-schema($avro_ex);
my Avro::DataFileWriter $writer = Avro::DataFileWriter.new(:handle($path.IO.open(:w)),:schema($schema));

# works ?
my %data = name => "Alyssa",source => "bar",address => {street1 => "foo"};
lives-ok {
 $writer.append(%data);
}, "Appended data causing issue";

lives-ok { 
 $writer.close;
}, "Sanity check";

# check that the read also works ... 
my $fh = $path.IO.open(:r);
my %result;
my Avro::DataFileReader $reader = Avro::DataFileReader.new(:handle($fh)); 
lives-ok { %result = $reader.read(); }, "Problem data read from file";
is "foo", %result{"address"}{"street1"}, "Correctly read problem data";

# clean up
unlink $path;

