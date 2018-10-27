if - conditionally use packages [![Build Status](https://secure.travis-ci.org/FROGGS/p6-if.svg?branch=master)](http://travis-ci.org/FROGGS/p6-if)
==
if, similar to Perl 5's pragma if will let you conditionally load packages.
Use cases (no pun intended)  are about loading different implementations of a functionality
for different operating systems, compiler backends, or compiler versions.

This means that these switches for different implementations do not happen at runtime,
but cheaply at compile time. This also means that a custom build and install hook
is not needed because all implementations are installed. Then depending on the conditions
only the desired implementation will be used.

Even if the switch is by backends you can share one installation by several backends using
this technique.

```perl6
use if; # activate the :if adverb on use statements

use My::Linux::Backend:if($*KERNEL.name eq 'linux');
use My::Fallback::Backend:if($*KERNEL.name ne 'linux');

# ... do something with the backend you got
```
INSTALLATION
--
```bash
panda install if
```
