use Digest::SHA1::Native;

use Test;

my $buf = Blob.new(76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76);

is sha1-hex($buf), 'fbb95b715b45ae7aeff031cd766da14392d2fef4', 'Blob';

done-testing;
