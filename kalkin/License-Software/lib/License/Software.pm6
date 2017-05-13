=NAME License::Software - provides templated software licenses

unit module License::Software;
use License::Software::Abstract;
use License::Software::GPLv3;
use License::Software::Apache2;
use License::Software::AGPLv3;
use License::Software::LGPLv3;
use License::Software::Artistic2;


=begin SYNOPSIS
=begin code
    use License::Software;
    my $author = 'Max Musterman';
    my $license = License::Software.get('gpl').new($author);

    say $license.name;          # Full license name
    say $license.short-name;    # Short name like 'GPLv3'
    say $license.alias;         # List of license alias
    say $license.url;           # License url
    say $license.header;        # License header
    ⋮                           # ⋮


=output The GNU General Public License, Version 3, 29 June 2007

=end code
=end SYNOPSIS

=begin DESCRIPTION

Applying a license to your software is not an easy task. Different licenses
dictate different usage and formatting rules. A prime example of a “complicated”
license is the GNU General Public License
(L<https://www.gnu.org/licenses/gpl.txt>) and the GNU Lesser General Public
License (L<https://www.gnu.org/licenses/lgpl.txt>).

The L<License::Software> provides a common interface for querying the software
license templates for data. Software licenses and their usage practices differ
greatly, but they have a number of common properties:

=item One or multiple copyright holders (authors).
=item Copyright notice per holder
=item Year or year range (i.e: 2000-2010) per holder
=item Copying permission, stating under which terms the software is distributed
=item Header to be added at the beginning of each licensed file
=item Minor things, like url, short-name, name aliases or how dates are formatted


Currently this module provides the following licenses:

=item AGPLv3.pm6
=item Apache2.pm6
=item Artistic2.pm6
=item GPLv3.pm6
=item LGPLv3.pm6

If your favorite license is missing please do a pull request.

=end DESCRIPTION

=USAGE
=begin pod
=head1 Getting the license class

=head2 License::Software::get-all

Return all supported licenses.

=head2 License::Software::get

    sub get(Str:D $alias)

Return the software license class for the given alias. I.e alias for the General
Public License 3 are 'GPLv3', 'GPL3' & 'GPL'.

=head2 License::Software::from-url

    sub from-url(Str:D $url)

Return the software license class for the given url. I.e
L<http://www.apache.org/licenses/LICENSE-2.0> is the url for Apache2 license.

=head1 License class methods

=head2 method new

    multi new(Str:D $name, $year?)

Expects a copyright holder name and an optional year. The license will use
'This program' as C<$works-name>.

    multi method new(Str:D $works-name, %h)
    multi method new(%h)

C<%h> is a hash where keys are the copyright holders names and values the
copyright year. If no C<$works-name> is provided it uses 'This program' by
default.

=head2 method header

    method header returns Str:D

Returns a C<Str> which should be added to each licensed file (source code) at
the top. I.e. GPL expects to have “This program is free software: you
can redistribute it and/or modify…” header at the top of each file.

=head2 method files

    method files returns Hash:D

Returns a C<Hash> where keys are file names and the value the file contents.
This is useful for licenses which dictate to have multiple different files. I.e.
Apache2 generates a 'LICENSE' and a 'NOTICE' file.

=head2 method full-text

    method full-text returns Str:D

Returns the full text of the license.

=head2 method name

    method name returns Str:D

Returns the full license name as C<Str>. I.e. for GPLv3 this would be “The GNU
General Public License, Version 3, 29 June 2007”

=head2 method short-name

    method short-name returns Str:D

Returns the short name for a license. I.e. 'GPLv3'.

=head2 method spdx

    method spdx returns Str:D

Returns the license L<https://spdx.org/|SPDX> identifier as C<Str>.

=head2 method note

    method note returns Str:D

Returns a short license text which can be used in README and Co.

=head2 submethod aliases

    submethod aliases returns Array[Str]

Returns all known alias' for the license.


=head3 submethod url

    submethod url returns Str:D

Returns the license url.


=end pod

our sub get-all returns List {
    return eager License::Software::.values.list ==> grep( {
        $_ ~~ License::Software::Abstract &&
        $_.^name !~~ 'License::Software::Abstract'
    })
    # ==> map *.^name.split('::')[*-1]
}

our sub get(Str:D $alias) returns License::Software::Abstract
{
    for get-all() -> $license { return $license if $alias.uc ∈ $license.aliases».uc }
    warn "Can not find license alias '$alias'";
}

our sub from-url(Str:D $url ) returns License::Software::Abstract
{
    for get-all() -> $license { return $license if $url ~~ $license.url }
    warn "Can not find license with url '$url'";
}
=COPYRIGHT Copyright © 2016 Bahtiar `kalkin-` Gadimov <bahtiar@gadimov.de>

=begin LICENSE
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.se v6;
=end LICENSE
