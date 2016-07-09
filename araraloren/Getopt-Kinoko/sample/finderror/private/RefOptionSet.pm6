
use v6;

use Getopt::Kinoko;

role RefOptionSet {
	has OptionSet $.optset;

	method optset() {
		$!optset;
	}
}