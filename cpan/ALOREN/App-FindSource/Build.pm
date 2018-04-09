
use Config::Searcher;

class Build {
	method build($work-dir) {
		my $config-dir = "{$work-dir}/config";

		# copy it to .findsource
		my $dest = &determind-local-path().add("findsource");

		$dest.mkdir unless $dest.e;
		for $config-dir.IO.dir() {
			.copy($dest.add(.basename));
		}
	}
}