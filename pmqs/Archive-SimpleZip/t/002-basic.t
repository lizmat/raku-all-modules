#!perl6 
 
use v6; 
use lib 'lib'; 
 
use Test; 
 
plan 15; 

use File::Temp;
use Archive::SimpleZip;

# Keep the test directory?
my $wipe = True;

my $base_dir_name = tempdir(:unlink($wipe));
ok $base_dir_name.IO.d, "tempdir { $base_dir_name } created";

ok chdir($base_dir_name), "chdir ok";

my $dir1 = 'dir1';
ok mkdir 0o777, $dir1 ;

my $zipfile = "test.zip" ;
my $datafile = "$dir1/data123";
my $datafile1 = "data124";

unlink $zipfile;
spurt $datafile, "some data" ;
spurt $datafile1, "more data" ;

ok   $datafile.IO.e, "$datafile does exists";
ok ! $zipfile.IO.e, "$zipfile does not exists";

my $zip = SimpleZip.new($zipfile, :stream, comment => 'file comment');
isa-ok $zip, SimpleZip;

ok $zip.add($datafile.IO), "add file";

ok $zip.add($datafile.IO, :name<new>), "add file but override name";
ok $zip.add("abcde", :name<fred>, comment => 'member comment'), "add string ok";
ok $zip.add("def", :name<joe>, :method(Zip-CM-Store), :stream), "add string, STORE";
ok $zip.close(), "closed";

ok $zipfile.IO.e, "$zipfile exists";


my Blob $data .= new();
my $zip2 = SimpleZip.new($data);
isa-ok $zip2, SimpleZip;
ok $zip2.add("abcde", :name<fred>), "add";
ok $zip2.close(), "closed";

#unlink $zipfile;

done-testing();

