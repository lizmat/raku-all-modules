# Semaphore Readers Writers Pattern or Light switch

[![Build Status](https://travis-ci.org/MARTIMM/mongo-perl6-driver.svg?branch=master)](https://travis-ci.org/MARTIMM/semaphore-readerswriters)
## Synopsis

```
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

## TODO

* Implement other variants of this pattern.
  * Readers priority variant
  * No writer starvation variant

## CHANGELOG

See [semantic versioning](http://semver.org/). Please note point 4. on that page: *Major version zero (0.y.z) is for initial development. Anything may change at any time. The public API should not be considered stable.*

* 0.2.2
  * Added $.debug to show messages about the actions. This will be deprecated later when I am confident enough that everything works well enaugh.
* 0.2.1
  * Removed debugging texts to publish class
* 0.2.0
  * Documentation
  * Bugfixes, hangups caused by overuse of same semaphores. Added more semaphores per critical section.
  * Preparations for other variations of this pattern
* 0.1.0 First tests
* 0.0.1 Setup

## LICENSE

Released under [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## AUTHORS

```
Marcel Timmerman
```
## CONTACT

MARTIMM on github: MARTIMM/mongo-perl6-driver
