use Digest::SHA256::Native;

use Test;

my $buf = Blob.new(76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76,76);

is sha256-hex($buf), '68a80ebf40baabc28573a5426c671b2a2afee67e4499df5462c46471f023f518', 'Blob';

done-testing;
