use v6.c;
use Test;
use Digest::BubbleBabble;

plan 3;

my %tests = (
    ''           => 'xexax',
    'Pineapple'  => 'xigak-nyryk-humil-bosek-sonax',
    '1234567890' => 'xesef-disof-gytuf-katof-movif-baxux'
);

subtest 'Encoding' => {
    plan +%tests * 2;
    for %tests.kv -> $digest, $fingerprint {
        my $result;
        lives-ok { $result = Digest::BubbleBabble.encode($digest.encode) }, "Encoding '$digest' succeeds";
        is $result.decode, $fingerprint, "Encoding '$digest' gives the correct fingerprint";
    }
}

subtest 'Decoding' => {
    plan +%tests * 2;
    for %tests.kv -> $digest, $fingerprint {
        my $result;
        lives-ok { $result = Digest::BubbleBabble.decode($fingerprint.encode) }, "Decoding '$fingerprint' succeeds";
        is $result.decode, $digest, "Decoding '$fingerprint' gives the correct digest";
    }
}

subtest 'Validating' => {
	my @failed-tests = ('sup my dudes', 'xaaaa', 'aaaax', 'xigak-nyryk-humil-bosek-soxyx');
	plan +%tests + +@failed-tests;

	for %tests.kv -> $, $fingerprint {
		is Digest::BubbleBabble.validate($fingerprint.encode), True, 'Can validate valid fingerprints';
	}

	for @failed-tests -> $fingerprint {
		is Digest::BubbleBabble.validate($fingerprint.encode), False, 'Can reject invalid fingerprints';
	}
}
