#!/usr/bin/env perl6

use Test;
use lib 'lib';
use Archive::Libarchive::Raw;

constant AUTHOR = ?%*ENV<TEST_AUTHOR>;

if AUTHOR {
  is archive_version_number, 3002001, 'version number';
  is archive_version_string, 'libarchive 3.2.1', 'version string';
  is archive_version_details, 'libarchive 3.2.1 zlib/1.2.8 liblzma/5.2.2 bz2lib/1.0.6 liblz4/1.7.1', 'version details';
  is archive_zlib_version, '1.2.8', 'linked zlib version';
  is archive_liblzma_version, '5.2.2', 'linked liblzma version';
  is archive_bzlib_version, '1.0.6, 6-Sept-2010', 'linked bzlib version';
  is archive_liblz4_version, '1.7.1', 'linked liblz4 version';
}else{
  skip 'version number', 1;
  skip 'version string', 1;
  skip 'version details', 1;
  skip 'linked zlib version', 1;
  skip 'linked liblzma version', 1;
  skip 'linked bzlib version', 1;
  skip 'linked liblz4 version', 1;
}

done-testing;
