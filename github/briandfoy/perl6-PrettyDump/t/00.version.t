use v6;

use Test;
use META6;

use PrettyDump;
constant package-name = 'PrettyDump';

my $module-version = PrettyDump.^ver;
ok $module-version.defined, 'Module specifies a version';
diag "Module version is $module-version";

my $meta-file = 'META6.json';
my $meta = META6.new: file => $meta-file;

my $meta-version = $meta.version;
ok $meta-version.defined, 'META6 specifies a version';
diag "META6 version is $meta-version";

is $meta-version, $module-version, 'META6 version matches module version';

done-testing();
