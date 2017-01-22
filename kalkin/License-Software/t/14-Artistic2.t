use v6;
use Test;
use License::Software;
use License::Software::Abstract;

plan 8;
ok my License::Software::Abstract $license = License::Software::get(<artistic>).new: "Bahtiar kalkin- Gadimov";
is $license.short-name(), 'Artistic2', 'Short license name';
is $license.name(), 'The Artistic License 2.0 (GPL Compatible)', 'Full license name';
is $license.aliases(), ['Artistic', 'Artistic2'], 'License Aliases';
is $license.files().keys, ['LICENSE'], 'License file';
is $license.header(), '', 'Artistic License does not need a header for each file';
is $license.files()<LICENSE>, $license.full-text(), 'Full Artistic2 Text';
is $license.url(), <http://www.perlfoundation.org/artistic_license_2_0>, 'The Artistic2 url';

# vim: ft=perl6
