use Test;

plan 7;

use Semantic::Versioning;

my $version = Semantic::Version.new;

is $version.version, "0.0.0";

$version.version = '3.4.2';

is $version.major-version, 3, 'major version from version';
is $version.minor-version, 4, 'minor version from version';
is $version.patch-version, 2, 'patch version from version';

$version.major-version = 1;
is $version.version, '1.4.2', 'version from major-version';

$version.minor-version = 6;
is $version.version, '1.6.2', 'version from minor-version';

$version.patch-version = 8;
is $version.version, '1.6.8', 'version from patch-version';

