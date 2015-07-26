use v6;
use Test;
use File::Compare;

plan 7;

sub sort-arrays (@arr) {
    # 2 layer sort to ensure test sameness
    # though in practice, order is less important
    my @x = map *.sort, @arr;
    my @y = @x.sort(*.[0]);
}

my @filelist = ("t/test-files/foobar-2.txt", "t/test-files/foobar.txt",
     "t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt",
     "t/test-files/empty1", "t/test-files/empty2");

is sort-arrays(compare_multiple_files(@filelist)),
  (["t/test-files/empty1", "t/test-files/empty2"],
   ["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],
   ["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"] ),
	"compare_multiple_files gets results";

is sort-arrays(compare_multiple_files(@filelist, chunk_size => 4)),
  (["t/test-files/empty1", "t/test-files/empty2"],
   ["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],
   ["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"] ),
	"compare multiple with chunk size";
	# but seriously never set chunk_size that low.
	# Do ~512 bytes, absolute minimum.

is sort-arrays(compare_multiple_files(@filelist.push('t/test-files/camelia.ico'))),
  (["t/test-files/empty1", "t/test-files/empty2"],
   ["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],
   ["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"] ),
	"non-matching files not returned";

dies-ok {say compare_multiple_files( [] )}, "empty array fails";

dies-ok {compare_multiple_files( [Mu, Any] )}, "wrong file data type passed fails";

dies-ok {compare_multiple_files( @filelist, chunk_size => -23 #`{Skidoo!} )}, "bad chunk_size parameter fails";

is sort-arrays(compare_multiple_files(@filelist».IO)),
  (["t/test-files/empty1", "t/test-files/empty2"],
   ["t/test-files/foo1/ab.txt", "t/test-files/foo2/ab.txt"],
   ["t/test-files/foobar-2.txt", "t/test-files/foobar.txt"] ),
	"IO::Path objects in list ok";
