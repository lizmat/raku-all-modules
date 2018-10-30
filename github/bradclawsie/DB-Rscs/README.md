[![License BSD](https://img.shields.io/badge/License-BSD-blue.svg)](http://opensource.org/licenses/BSD-3-Clause)
[![Build Status](https://travis-ci.org/bradclawsie/DB-Rscs.png)](https://travis-ci.org/bradclawsie/DB-Rscs)

# DB::Rscs

A client library for the **R**idiculously **S**imple **C**onfiguration
**S**ystem. [https://github.com/bradclawsie/rscs](https://github.com/bradclawsie/rscs) 

(also available at gitlab: [https://gitlab.com/bradclawsie/rscs](https://gitlab.com/bradclawsie/rscs))

RSCS only stores keys and values and only allows simple CRUD
operations. It is supposed to underwhelm you.

This library is a Perl6 client for RSCS.

## SYNOPSIS

```
# Assuming you have rscs running on port 8081.

use v6;
use DB::Rscs;

my $rscs = DB::Rscs.new(addr=>'http://localhost:8081');
my $val = 'val1';
my $key = 'key1';
$rscs.insert($key,$val);
my %out = $rscs.get($key);
say %out{$VALUE_KEY};
$rscs.update($key,'a new val');
$rscs.delete($key);
```

## TESTING

DB::Rscs has a unit test file that will only be run in full through
the Travis CI link https://travis-ci.org/bradclawsie/DB-Rscs which
is the target of the build badge above. During installation via `zef`
the full test suite is not run since it requires a local executable
copy of the `rscs` daemon (https://travis-ci.org/bradclawsie/rscs),
which I do not want to retrieve as part of the zef library install process. I
expect users will obtain this program on their own using the command
`go get github.com/bradclawsie/rscs`. 

If you wish to run the unit tests *after* installation, just set the
environment variables `TRAVIS` and `CI` to be true and rerun the tests.

## AUTHOR

Brad Clawsie (PAUSE:bradclawsie, email:brad@b7j0c.org)

## LICENSE

This module is licensed under the BSD license, see: https://b7j0c.org/stuff/license.txt

