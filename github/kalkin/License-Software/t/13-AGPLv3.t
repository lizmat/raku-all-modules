use v6;
use Test;
use License::Software;
use License::Software::Abstract;
plan 11;

ok my License::Software::Abstract $license = License::Software::get(<agplv3>).new: "Bahtiar kalkin- Gadimov";
is $license.short-name(), 'AGPLv3', 'Short license name';
is $license.name(), 'The GNU Affero General Public License, Version 3, 29 June 2007', 'Full license name';
is $license.works-name(), 'This program', "Default program name should 'This program'";
ok $license.full-text(), 'The full text of the AGPLv3 license';
ok $license.header(), 'Header to prepend in files';
ok $license.files(), 'License files';
ok $license.files()<COPYING>, $license.full-text();
is $license.aliases(), ['AGPLv3', 'AGPL3', 'AGPL', $license.spdx], 'License Aliases';
is $license.url(), <https://www.gnu.org/licenses/agpl-3.0.txt>;
ok $license.note(), 'Short note to use in README and similar';

# vim: ft=perl6
