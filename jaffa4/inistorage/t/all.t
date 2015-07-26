use v6;

use Ini::Storage;
use Test;
plan *;

my $o = Ini::Storage.new("storage_test333",False);

ok $o, "construction";


#note $o.GetFilename();
ok $o.GetFilename ~~ /storage_test333$/,"construction 2";



$o.Write("g/id",7);

ok $o.Exists("g/id"), "existance";

#say "GetEntryName:"~$o.GetEntryName("g",1); #first

ok $o.Read("g/id",0)==7, "read/write test";

#say $o.CountEntries("g");

ok $o.CountEntries("g") == 1, "counting";

ok $o.GetEntryName("g",1) eq "id", "getting entry name";

ok $o.GroupExists("g"), "group existance";

$o.RenameEntry("g/id","g/no");


ok $o.GetEntryName("g", 1) eq "no", "rename entry";


$o.SetDisk(True);
my $f = $o.GetFilename;

$o.Write("g/text","d\\
next
");

$o.SetArrayInGroup("record","a",(3,1,4,8,3)); 

$o.Flush;

ok $f.IO ~~ :e, "file is saved";




$o.DeleteEntry("g/no");

ok $o.CountEntries("g") == 1, "deleting entry";


$o.Write("a/id",1);

my $o2 = Ini::Storage.new("storage_test333",True);


ok $o2.Read("g/no",0)==7, "file read test";

ok $o2.Read("g/text",0) eq "d\\
next
", "file read test 2";

$o2.Exchange("g/text","g/no");

ok $o2.Read("g/no",0) eq "d\\
next
", "Exchange text";


my @a = $o2.GetArrayInGroupK("record/a");


#say @a.perl;
ok @a ~~ ["3","1","4","8","3"], "loading an array";

$o2.SetDisk(False);

#say $o2.perl;

unlink $f;

done;