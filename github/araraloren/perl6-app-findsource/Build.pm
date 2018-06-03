
use Config::Searcher;

class Build {
	method build($work-dir) {
		my $config-dir = "{$work-dir}/config";

		# copy it to .findsource
		my $dest = &determind-local-path().add("findsource");

		$dest.mkdir unless $dest.e;
		for $config-dir.IO.dir() {
			note "copy {.basename} to {$dest.path}";
			.copy($dest.add(.basename));
		}
		True; # seems like we need return True to `zef`
	}
}
