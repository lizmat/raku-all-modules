[![Build Status](https://travis-ci.org/kalkin/License-Software.svg?branch=master)](https://travis-ci.org/kalkin/License-Software)

NAME
====

License::Software - provides templated software licenses

SYNOPSIS
========

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

DESCRIPTION
===========

Applying a license to your software is not an easy task. Different licenses dictate different usage and formatting rules. A prime example of a “complicated” license is the GNU General Public License ([https://www.gnu.org/licenses/gpl.txt](https://www.gnu.org/licenses/gpl.txt)) and the GNU Lesser General Public License ([https://www.gnu.org/licenses/lgpl.txt](https://www.gnu.org/licenses/lgpl.txt)).

The [License::Software](License::Software) provides a common interface for querying the software license templates for data. Software licenses and their usage practices differ greatly, but they have a number of common properties:

  * One or multiple copyright holders (authors).

  * Copyright notice per holder

  * Year or year range (i.e: 2000-2010) per holder

  * Copying permission, stating under which terms the software is distributed

  * Header to be added at the beginning of each licensed file

  * Minor things, like url, short-name, name aliases or how dates are formatted

Currently this module provides the following licenses:

  * AGPLv3.pm6

  * Apache2.pm6

  * Artistic2.pm6

  * GPLv3.pm6

  * LGPLv3.pm6

If your favorite license is missing please do a pull request.

USAGE
=====



Getting the license class
=========================

License::Software::get-all
--------------------------

Return all supported licenses.

License::Software::get
----------------------

    sub get(Str:D $alias)

Return the software license class for the given alias. I.e alias for the General Public License 3 are 'GPLv3', 'GPL3' & 'GPL'.

License::Software::from-url
---------------------------

    sub from-url(Str:D $url)

Return the software license class for the given url. I.e [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0) is the url for Apache2 license.

License class methods
=====================

method new
----------

    multi new(Str:D $name, $year?)

Expects a copyright holder name and an optional year. The license will use 'This program' as `$works-name`.

    multi method new(Str:D $works-name, %h)
    multi method new(%h)

`%h` is a hash where keys are the copyright holders names and values the copyright year. If no `$works-name` is provided it uses 'This program' by default.

method header
-------------

    method header returns Str:D

Returns a `Str` which should be added to each licensed file (source code) at the top. I.e. GPL expects to have “This program is free software: you can redistribute it and/or modify…” header at the top of each file.

method files
------------

    method files returns Hash:D

Returns a `Hash` where keys are file names and the value the file contents. This is useful for licenses which dictate to have multiple different files. I.e. Apache2 generates a 'LICENSE' and a 'NOTICE' file.

method full-text
----------------

    method full-text returns Str:D

Returns the full text of the license.

method name
-----------

    method name returns Str:D

Returns the full license name as `Str`. I.e. for GPLv3 this would be “The GNU General Public License, Version 3, 29 June 2007”

    method short-name returns Str:D

Returns the short name for a license. I.e. 'GPLv3'.

method note
-----------

    method note returns Str:D

Returns a short license text which can be used in README and Co.

submethod aliases
-----------------

    submethod aliases returns Array[Str]

Returns all known alias' for the license.

### submethod url

    submethod url returns Str:D

Returns the license url.

COPYRIGHT
=========

Copyright © 2016 Bahtiar `kalkin-` Gadimov <bahtiar@gadimov.de>

LICENSE
=======

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.se v6;
