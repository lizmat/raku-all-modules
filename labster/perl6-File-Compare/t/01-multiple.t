use v6;
use Test;
use File::Compare;

plan 7;

my @filelist = ("t/test-files/foobar-2.txt", "t/test-files/foobar.txt",
     "t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt",
     "t/test-files/empty1", "t/test-files/empty2");

is compare_multiple_files(@filelist)».path,
  (["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"],
     ["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],
     ["t/test-files/empty1", "t/test-files/empty2"]),
	"compare_multiple_files gets results";

is compare_multiple_files(@filelist, chunk_size => 4)».path,
  (["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"],
     ["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],
     ["t/test-files/empty1", "t/test-files/empty2"]),
	"compare multiple with chunk size";
	# but seriously never set chunk_size that low.
	# Do ~512 bytes, absolute minimum.

is compare_multiple_files(@filelist.push('t/test-files/camelia.ico'))».path,
  (["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"],
     ["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],
     ["t/test-files/empty1", "t/test-files/empty2"]),
	"non-matching files not returned";

dies_ok {say compare_multiple_files( [] )}, "empty array fails";

dies_ok {compare_multiple_files( [Mu, Any] )}, "wrong file data type passed fails";

dies_ok {compare_multiple_files( @filelist, chunk_size => -23 #`{Skidoo!} )}, "bad chunk_size parameter fails";

is compare_multiple_files(@filelist».path)».path,
  (["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"],
     ["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],
     ["t/test-files/empty1", "t/test-files/empty2"]),
	"IO::Path objects in list ok";
