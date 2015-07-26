use v6;
use Test;
use lib 'lib';
use Avro; 
use Avro::DataFile;

plan 10;

#======================================
# Test Setup
#======================================

my $path = "datafile";
my $avro_ex = Q<<{
 "type": "record",
 "name": "Data",
 "fields": [
     {"name": "name", "type": "string"},
     {"name": "number",  "type": ["int", "null"]},
     {"name": "list", "type" : { "type": "array", "items": "string" } }
 ]
}>>;


my Avro::Schema $schema = parse-schema($avro_ex);
my Avro::DataFileWriter $writer; 
my Avro::DataFileReader $reader; 
my IO::Handle $fh;
my %result;
my %data;


#======================================
# Test :: File Header Writes & Reads
#======================================

# creates a file
$fh = $path.IO.open(:w);
lives-ok {$writer = Avro::DataFileWriter.new(:handle($fh),:schema($schema),:encoding(Avro::Encoding::Binary))}, "Opened Data File";
$writer.close;
$fh = $path.IO.open(:r);
lives-ok {$reader = Avro::DataFileReader.new(:handle($fh)); }, "Read Empty Data File";
$fh.close;


#======================================
# Test :: write and read data
#======================================

$fh = $path.IO.open(:w);
%data = "name" => "Aaron","number" => 1024 , list => [ "hello", "world" ];
$writer = Avro::DataFileWriter.new(:handle($fh),:schema($schema),:encoding(Avro::Encoding::Binary));
lives-ok { $writer.append(%data); }, "Appended data";
$writer.close;
$fh = $path.IO.open(:r);
$reader = Avro::DataFileReader.new(:handle($fh)); 
lives-ok { %result = $reader.read(); }, "Data read from file";
is-deeply %data, %result, "Correct data read";
$fh.close;


#======================================
# Test :: eof
#======================================

$fh = $path.IO.open(:w);
%data = "name" => "Aaron","number" => 1 , list => [];
$writer = Avro::DataFileWriter.new(:handle($fh),:schema($schema));
my Int $count = 20;
loop (my $i = 0; $i < $count; $i++) {
  $writer.append(%data);
}
$writer.close;
$fh = $path.IO.open(:r);
$reader = Avro::DataFileReader.new(:handle($fh)); 
repeat {
  $reader.read();
  $count--;
} until $reader.eof;
is $count,0,"Eof work correctly";
$fh.close;


#======================================
# Test :: slurp
#======================================

$fh = $path.IO.open(:w);
%data = "name" => "Aaron","number" => 1 , list => [];
$writer = Avro::DataFileWriter.new(:handle($fh),:schema($schema));
$count = 20;
loop ($i = 0; $i < $count; $i++) {
  $writer.append(%data);
}
$writer.close;
$fh = $path.IO.open(:r);
$reader = Avro::DataFileReader.new(:handle($fh)); 
my @arr = $reader.slurp;
$fh.close;
is +@arr,$count, "Slurp works";


#======================================
# Test :: compatability
#======================================

my $rsc = "t/users.avro";
$fh = $rsc.IO.open(:r);
lives-ok {$reader = Avro::DataFileReader.new(:handle($fh)); }, "Read python created data";
lives-ok { %result = $reader.read(); }, "Data read from python file";
%data = "name" => "Alyssa","favorite_number" => 256, "favorite_color" => Any;
is-deeply %data, %result, "Correct data read from python data";

# clean up
unlink $path;

# vim: filetype=perl6
