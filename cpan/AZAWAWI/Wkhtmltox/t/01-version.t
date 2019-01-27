use v6;

use Test;
use Wkhtmltox::PDF;

plan 1;

my $version = Wkhtmltox::PDF.version;

diag $version.perl;
ok $version ~~ Str, "Version is a string";
