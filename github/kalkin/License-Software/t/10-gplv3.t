use v6;
use Test;
use License::Software;
use License::Software::Abstract;

plan 10;

ok my License::Software::Abstract $license = License::Software::get('gplv3').new: "Max Musterman";
is $license.short-name(), 'GPLv3', 'Short license name';
is $license.name(), 'The GNU General Public License, Version 3, 29 June 2007', 'Full license name';
is $license.works-name(), 'This program', "Default program name should 'This program'";
ok $license.full-text(), 'The full text of the GPLv3 license';
ok $license.files(), 'License files';
is $license.aliases(), ['GPLv3', 'GPL3', 'GPL', $license.spdx], 'License Aliases';
is $license.url(), <https://www.gnu.org/licenses/gpl-3.0.txt>;
ok $license.note(), 'Short note to use in README and similar';
ok $license.header(), 'Header to prepend in files';

# vim: ft=perl6
