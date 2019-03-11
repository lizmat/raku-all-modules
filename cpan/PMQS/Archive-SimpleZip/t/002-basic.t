#!perl6 
 
use v6; 
use lib 'lib'; 
use lib 't'; 
 
use Test; 
 
plan 5; 

use ZipTest; 

if ! external-zip-works()
{
    skip-rest("Cannot find external zip/unzip or they do not work as expected.");
    exit;
}

use File::Temp;
use Archive::SimpleZip ;
use Archive::SimpleZip::Utils;

# Keep the test directory?
my $wipe = False;

my $base_dir_name = tempdir(:unlink($wipe));
ok $base_dir_name.IO.d, "tempdir { $base_dir_name } created";

ok chdir($base_dir_name), "chdir ok";

my $dir1 = 'dir1';
ok mkdir $dir1, 0o777;

my $zipfile = "test.zip" ;
my $datafile = "$dir1/data123";
my $datafile1 = "data124";
my $datafile2 = "data125".IO;

subtest
{
    unlink $zipfile;
    spurt $datafile, "some data" ;
    spurt $datafile1, "more data" ;
    my $text = "line 1\nline 2\nline 3";
    
    spurt $datafile2, $text ;

    ok  $datafile.IO.e, "$datafile does exists";
    nok $zipfile.IO.e, "$zipfile does not exists";

    my $zip = SimpleZip.new($zipfile, :stream, comment => 'file comment');
    isa-ok $zip, SimpleZip;

    ok $zip.add($datafile1.IO), "add file";
    ok $zip.add($datafile.IO, :name<new>), "add file but override name";
    ok $zip.add("abcde", :name<fred>, comment => 'member comment'), "add string ok";
    ok $zip.add("def", :name</joe//bad>, :method(Zip-CM-Store), :stream, :!canonical-name), "add string, STORE";
    ok $zip.add(Buf.new([2,4,6]), :name</jim/>, :method(Zip-CM-Bzip2), :stream), "add string, STORE";
    ok $zip.add($datafile2.open, :name<handle>), "Add filehandle";
    ok $zip.close(), "closed";

    ok $zipfile.IO.e, "$zipfile exists";

    ok test-with-unzip($zipfile), "unzip likes the zip file";

    # is comment-from-unzip($zipfile), "file comment", "File comment ok";
    is pipe-in-from-unzip($zipfile, 'new'), "some data", "member new ok";
    is pipe-in-from-unzip($zipfile, $datafile1), "more data", "member $datafile1 ok";
    is pipe-in-from-unzip($zipfile, "fred"), "abcde", "member fred ok";
    is pipe-in-from-unzip($zipfile, "/joe//bad"), "def", "member /joe//bad ok";
    is pipe-in-from-unzip($zipfile, "jim", :binary).decode, "\x2\x4\x6", "member jim ok";
    is pipe-in-from-unzip($zipfile, "handle"), $text, "member handle ok";

    # Write zip to Blob

    # my Blob $data .= new();
    # my $zip2 = SimpleZip.new($data);
    # isa-ok $zip2, SimpleZip;
    # ok $zip2.add("abcde", :name<fred>), "add";
    # ok $zip2.close(), "closed";

    # my $file2 = "file2.zip".IO;
    # spurt $file2, $data, :bin;
    # ok $file2.e, "$file2 does exists";
    # ok $file2.s, "$file2 not empty";

    # diag "File size { $file2.s }\n";

    # ok test-with-unzip($file2), "unzip likes the zip file";

    # is pipe-in-from-unzip($file2, 'fred'), "abcde", "member fred ok";
}, 'add' ;

subtest
{
    unlink $zipfile;
    spurt $datafile, "some data" ;
    spurt $datafile1, "more data" ;

    ok  $datafile.IO.e, "$datafile does exists";
    nok $zipfile.IO.e, "$zipfile does not exists";

    my $zip = SimpleZip.new($zipfile);
    isa-ok $zip, SimpleZip;

    ok $zip.add($datafile1.IO, :name("\c[GREEK SMALL LETTER ALPHA]")), "add file";
}, "language encoding bit";

done-testing();
