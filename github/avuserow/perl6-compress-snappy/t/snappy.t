use v6;

use Compress::Snappy;
use Test;

multi roundtrip-test(Str $in, Str $label) {
	my $compressed = Compress::Snappy::compress($in);
	ok Compress::Snappy::validate($compressed), "validate on $label (Str)";
	my $decompressed = Compress::Snappy::decompress($compressed);
	is $decompressed.decode('utf8'), $in, "roundtrip on $label (Str)";
}

multi roundtrip-test(Blob $in, Str $label) {
	my $compressed = Compress::Snappy::compress($in);
	ok Compress::Snappy::validate($compressed), "validate on $label (Blob)";
	my $decompressed = Compress::Snappy::decompress($compressed);
	is $decompressed, $in, "roundtrip on $label (Blob)";
}

roundtrip-test '', 'empty string';

roundtrip-test 'Hello, world!', 'short greeting';

roundtrip-test '0' x 1024, '1k of zeroes';

roundtrip-test ([~] 'a' .. 'z') x 100, '100 alphabets';

roundtrip-test '»ö« .oO(æ€!éè)' x 100, '100 strings with unicode characters';

roundtrip-test Buf.new(0 .. 9), 'short binary Buf';

roundtrip-test Buf.new(|(0 .. 9) xx 1000), 'long binary Buf';

done-testing;
