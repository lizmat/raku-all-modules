
use v6;

=begin pod

=head1 NAME

License::SPDX  - Abstraction over the L<https://spdx.org/licenses/|SPDX License List>

=head1 SYNOPSIs

=begin code

use License::SPDX;

my $l = License::SPDX.new;

if $l.get-license('Artistic-2.0') -> $license {
	pass "licence is good";
	if $license.is-deprecated-license {
		warn "deprecated licence";
    }
}
else {
	flunk "not a good licence";
}

=end code

=head1 DESCRIPTION

This provides an abstraction over the  SPDX License List as provided in
JSON format Its primary raison d'être is to help the licence checking
of L<https://github.com/jonathanstowe/Test-META|Test::META> and to allow
for the warning about deprecated licences therein.

The intention is to update this with a new license list (and up the
version,) every time the SPDX list is updated.

=head2 ATTRIBUTES

=head3  Str $.license-list-version

This is the version of the license list being used.

=head3 Data $.release-date

This is the date that this release of the license list was generated.

=head3 License @.licenses

This is a list of the L<License::SPDX::License> objects from the list.

=head2 License::SPDX::License

=head3 reference 

Reference to the HTML format for the license file.  This is relative to the license file repository root.

=head3 is-deprecated-license

True if the entire license is deprecated.

=head3 details-url 

URL to a JSON file containing the license detailed information. This may be relative to the source of the JSON list.

=head3 reference-number 

Generated number

=head3 name 

License name

=head3 license-id 

License identifier - this is the common identifier that should be used in the META6 license field.

=head3 see-also 

A list of cross reference URL pointing to additional copies of the license.

=head3 is-osi-approved 

A Bool that indicates if the OSI has approved the license


=head2 METHODS

=head3 method get-license

    method get-license( Str:D $id --> License )

This returns the License object identified by the supplied id
or a License type object if it isn't found.


=end pod

use JSON::Name;

use JSON::Class;

class License::SPDX does JSON::Class {
    class License does JSON::Class {
        has Str     $.name;
        has Bool    $.is-deprecated-license     is json-name('isDeprecatedLicenseId');
        has Bool    $.is-osi-approved           is json-name('isOsiApproved');
        has Str     $.license-id                is json-name('licenseId');
        has Str     $.reference;
        has Str     $.details-url               is json-name('detailsUrl');
        has Str     @.see-also                  is json-name('seeAlso');
        has Str     $.reference-snumber         is json-name('referenceNumber');
        has Bool    $.is-fsf-libre              is json-name('isFsfLibre');
    }
    has Str     $.license-list-version  is json-name('licenseListVersion');
    has Date     $.release-date          is json-name('releaseDate') is unmarshalled-by( -> $d { Date.new($d) });
    has License @.licenses;

    has License %.license-by-id         is json-skip;

    method license-by-id( --> Hash ) {
        %!license-by-id ||= @!licenses.map(-> $l { $l.license-id => $l }).Hash;
    }

    method get-license( Str:D $id --> License ) {
        self.license-by-id{$id} || License;
    }

    has Str @.license-ids               is json-skip;

    method license-ids( --> Array ) {
        @!license-ids ||= self.license-by-id.keys.Array;
    }

    multi method new(*%v where { not $_.keys }) {
        self.from-json(%?RESOURCES<data/licenses.json>.slurp);
    }
}

# vim: ft=perl6
