use v6;
use Panda::Common;
use Panda::Builder;
use Shell::Command;

class Build is Panda::Builder {
	method build($dir) {
		my $so = 'unix_privileges.so';
		my $blib = "$dir/blib";
		rm_rf($so);
		rm_rf($blib);
		mkdir($blib);
		mkdir("$blib/lib");
		shell("make");
		cp($so, "$blib/lib/$so");
		rm_rf($so);
	}
}
