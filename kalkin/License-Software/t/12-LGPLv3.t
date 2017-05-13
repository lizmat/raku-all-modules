use v6;
use Test;
use License::Software;
use License::Software::Abstract;

plan 7;

ok my License::Software::Abstract $license = License::Software::get('lgplv3').new("Bahtiar kalkin- Gadimov");
is $license.short-name(), 'LGPLv3', 'Short license name';
is $license.name(), 'The GNU Lesser General Public License, Version 3, 29 June 2007', 'Full license name';
is $license.aliases(), ['LGPLv3', 'LGPL3', 'LGPL', $license.spdx], 'License Aliases';
is $license.files().keys, ['COPYING.LESSER', 'COPYING'], 'License files';

my $gpl = License::Software::get('gplv3').new("Bahtiar kalkin- Gadimov");
is $license.files()<COPYING>, $gpl.full-text(), 'Fill GPL3 Text';
is $license.url(), <https://www.gnu.org/licenses/lgpl-3.0.txt>, 'The LGPLv3 url';

# vim: ft=perl6
