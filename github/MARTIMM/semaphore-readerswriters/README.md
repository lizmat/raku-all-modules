# Semaphore Readers Writers Pattern or Light switch

[![Build Status](https://travis-ci.org/MARTIMM/semaphore-readerswriters.svg?branch=master)](https://travis-ci.org/MARTIMM/semaphore-readerswriters)  [![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

## Synopsis

```perl6 {cmd:true}
use Semaphore::ReadersWriters;

my Semaphore::ReadersWriters $rw .= new;
$rw.add-mutex-names('shv');
my $shared-var = 10;

# After creating threads ...
# Some writer thread
$rw.writer( 'shv', {$shared-var += 2});

# Some reader thread
say 'Shared var is ', $rw.reader( 'shv', {$shared-var;});
```

# Documentation

The Markdown files in this package uses the atom plugin **Markdown Preview Enhanced**. E.g. the synopsis can be run by placing the cursor in the code and type `shift-enter' or, if not possible, look for the readme pdf in doc)

* [README pdf](https://github.com/MARTIMM/semaphore-readerswriters/blob/master/doc/README.pdf)
* [ReadersWriters pdf](https://github.com/MARTIMM/semaphore-readerswriters/blob/master/doc/ReadersWriters.pdf)

## TODO

* Implement other variants of this pattern.
  * Readers priority variant.
  * No writer starvation variant.
  * Document return value restrictions. Only items, no List.

## CHANGELOG

See [semantic versioning](http://semver.org/). Please note point 4. on that page: *Major version zero (0.y.z) is for initial development. Anything may change at any time. The public API should not be considered stable.*

* 0.2.6
  * Methods `reader` and `writer` returned a failure object when things are wrong. This poses a problem in some situations. Now it will throw an exception.
* 0.2.5
  * Changed last method into check-mutex-names() to test for more than one name.
* 0.2.4
  * Added convenience method check-mutex-name().
* 0.2.3
  * add-mutex-names throws an exception when keys are reused
* 0.2.2
  * Added $.debug to show messages about the actions. This will be deprecated later when I am confident enough that everything works well enough.
* 0.2.1
  * Removed debugging texts to publish class
* 0.2.0
  * Documentation
  * Bugfixes, hangups caused by overuse of same semaphores. Added more semaphores per critical section.
  * Preparations for other variations of this pattern
* 0.1.0 First tests
* 0.0.1 Setup

# Other info
## Perl6 version
Tested on the latest version of perl6 on moarvm

## Install
Install package using zef
```
zef install Semaphore::ReadersWriters
```

## Author
Marcel Timmerman

## Contact
MARTIMM on github
