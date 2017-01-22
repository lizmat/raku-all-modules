#!/usr/bin/env perl6

use lib 'lib';
use Archive::Libarchive;
use Test;
plan 7;

constant AUTHOR = ?%*ENV<TEST_AUTHOR>; 

if AUTHOR { 
  my Archive::Libarchive $a .= new(operation => LibarchiveRead);
  my %vers = $a.lib-version;
  is %vers<ver>,     '3002001', 'libarchive version';
  is %vers<strver>,  'libarchive 3.2.1', 'libarchive version as string';
  is %vers<details>, 'libarchive 3.2.1 zlib/1.2.8 liblzma/5.2.2 bz2lib/1.0.6 liblz4/1.7.1', 'libarchive version details';
  is %vers<liblzma>, '5.2.2', 'liblzma version';
  is %vers<liblz4>,  '1.7.1', 'liblz4 version';
  is %vers<bzlib>,   '1.0.6, 6-Sept-2010', 'bzlib version';
  is %vers<zlib>,    '1.2.8', 'zlib version';
}else{
  skip-rest 'Skipping author test';
  exit;
}
