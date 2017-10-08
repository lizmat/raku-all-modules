# Ini::Storage

Read/write ini files and manipulate them in memory.
Groups in function names refer to sections.
Key refers to "group/key" format.



## Usage

    use Ini::Storage;

    my $o = Ini::Storage.new("my.cfg",True); # True -> read from disk immediately if it exists.
    $o.Write("g/id",7); # write section g with key id = 7
    

    my $v = $o.Read("g/id",0); # read section g with key id... if it is not found return 0


    $o.FLush; # write to disk

    $o.SetDisk(False); # will not write anything to disk, even when object destructs



##functions
	method new($filename,$isdisk)
	method GetFilename 
	method SetFilename($newfn) 
	method Read($key,$default) 
	method Exchange($key,$key2) 
	method GetEntryName($group,$no is copy)
	method Write($key,$value) 
	method Copy($obj) 
	method CountEntries($group) 
	method CopyGroup($obj,$group,$newgroupname?) 
	method DeleteEntry($key) 
	method RenameEntry($key,$keynew)
	method DeleteEntryFromArray($key)
	method GetLastArrayIndex($key)
	method DeleteGroup($group) 
	method GroupExists($group)
	method Exists($key) 
	method GetGroups
	method GetEntriesInGroup($group) 
	method FindIndexInArrayByValue($group,$arrayname,$value) 
	method FindAValueInRecordByKey($group,$arrayname,$value,$arrayname2) 
	method GetArrayInGroupK($key) 
	method GetArrayInGroupGE($group,$name) 
	method SetArrayInGroup ($group,$name,@arr) 
	method ReadFile()
	method WriteFile 
	method PrintGroup($group) 
	method SetDisk($disk)
	method Flush 


