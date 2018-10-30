# LMDB

LMDB is a native Perl6 bindings for the OpenLDAP's lmdb (Lightning
Memory-Mapped Database) C library.

lmdb is an ultra-fast, ultra-compact key-value data store developed
by Symas for the OpenLDAP Project. See http://symas.com/mdb/ for details.

## PREREQUISITES

Right now lmdb needs a 64bits platform.

Before you can install LMDB you need to have the following installed
on your system:

* Rakudo 2015.12 or superior

* lmdb Version 0.9.17 or greater.

  You can get the latest version from https://github.com/LMDB/lmdb.

  Some Linux distributions are now including it:

  * Fedora 20+

    `yum install lmdb-devel`

  * Ubuntu

    `apt-get install liblmdb-dev`

* The lmdb library must be compiled and installed for the NativeCall machinery to found it

## INSTALLATION

You install this module with panda:

    panda install LMDB

## USE

See QUICK-GUIDE.md


*** WARNING ***
This is an early release to allow the interested people the testing and
discussion of the module: there is some missing features and you should
be aware that the API isn't in stone yet. See TODO

## COPYRIGHT

Copyright © 2016 by Salvador Ortiz Garcia
