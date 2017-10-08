#!/usr/bin/env perl6

use Test;
use lib 'lib';
use Archive::Libarchive;
use Archive::Libarchive::Constants;

my Archive::Libarchive::Entry $e1 .= new: operation => LibarchiveWrite;
is $e1.entry.defined, True, 'Create entry';
lives-ok { $e1.pathname('test.tar.gz') }, 'Set entry pathname';
$e1.free;
my Archive::Libarchive::Entry $e2 .= new;
throws-like
  { $e2.size(500) },
  X::Libarchive,
  message => /'Read-only entry'/,
  'Set size on read-only entry fails';

done-testing;
