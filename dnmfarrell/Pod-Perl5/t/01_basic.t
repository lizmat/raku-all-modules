use Test;
use lib 'lib';

plan 5;

use Pod::Perl5; pass "Import Pod::Perl5";

my $expected_html = 'test-corpus/output.html'.IO.slurp;

ok my $string_match = Pod::Perl5::parse-string("=pod\n\nParagraph 1\n\n=cut\n"), 'parse string';
ok my $file_match   = Pod::Perl5::parse-file('test-corpus/readme_example.pod'), 'parse document';
ok my $html_from_file = Pod::Perl5::file-to-html('test-corpus/readme_example.pod'), 'parse document';
is $html_from_file, $expected_html, 'Converted html matches expected';
