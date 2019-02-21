# License::SPDX

Abstraction over the [SPDX License List](https://spdx.org/licenses/)

## Synopsis

```perl6

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

```

## Description

This provides an abstraction over the  [SPDX License List](https://spdx.org/licenses/)
as provided in [JSON format](https://github.com/spdx/license-list-data/blob/master/json/licenses.json).
Its primary raison d'être is to help the licence checking of [Test::META](https://github.com/jonathanstowe/Test-META)
and to allow for the warning about deprecated licences therein.

The intention is to update this with a new license list (and up the version,) every time the SPDX list is updated.


## Installation

Assuming that you have a working Rakudo Perl 6 compiler you should be able to install this using *zef* :

    zef install License::SPDX

    # Or from a local clone

    zef install .

## Support

This is a very simple module, but if you have any
suggestions or patches etc please send them to https://github.com/jonathanstowe/License-SPDX/issues

## Licence & Copyright

This is free software, please the [LICENCE](LICENCE) in the distribution.

© Jonathan Stowe 2019

The SPDX Data licensing is described [here](https://github.com/spdx/license-list-data/blob/master/accessingLicenses.md#tech-report-license),
the JSON data is included verbatim from source.
