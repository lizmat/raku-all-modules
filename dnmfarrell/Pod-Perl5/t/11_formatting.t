use Test;
use lib 'lib';

plan 2;

use Pod::Perl5; pass "Import Pod::Perl5";

ok my $match = Pod::Perl5::parse-file('test-corpus/formatting_codes.pod'),
  'parse formatting codes';

