use v6;

use Compress::Snappy;
use Test;

multi roundtrip-test(Str $in, Str $label) {
	my $compressed = Compress::Snappy::compress($in, 'utf-8');
	ok Compress::Snappy::validate($compressed), "validate on $label (Str)";
	my $decompressed = Compress::Snappy::decompress($compressed, 'utf-8');
	is $decompressed, $in, "roundtrip on $label (Str)";
}

roundtrip-test '', 'empty string';

roundtrip-test 'Hello, world!', 'short greeting';

roundtrip-test '0' x 1024, '1k of zeroes';

roundtrip-test ([~] 'a' .. 'z') x 100, '100 alphabets';

roundtrip-test '»ö« .oO(æ€!éè)' x 100, '100 strings with unicode characters';

done-testing;
