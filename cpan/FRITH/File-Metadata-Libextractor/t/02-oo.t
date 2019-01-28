#!/usr/bin/env perl6

use Test;
use lib 'lib';
use File::Metadata::Libextractor;
use File::Metadata::Libextractor::Constants;

my File::Metadata::Libextractor $le .= new;
isa-ok $le, File::Metadata::Libextractor, 'simple initialization';
my @info = $le.extract($*PROGRAM-NAME);
is @info[0]<plugin-name>, 'mime', 'plugin name';
is @info[0]<plugin-type>, 'EXTRACTOR_METATYPE_MIMETYPE', 'plugin type';
is @info[0]<plugin-format>, 'EXTRACTOR_METAFORMAT_UTF8', 'plugin format';
is @info[0]<mime-type>, 'text/plain', 'mime type';
like @info[0]<data-type>, /text/, 'data type';
lives-ok {my @promises;
          for ^5 { @promises.push: start {$le.extract: $*PROGRAM-NAME } }
          await @promises },
         'concurrency';
subtest {
  my File::Metadata::Libextractor $leip .= new: :in-process;
  my @infole = $leip.extract($*PROGRAM-NAME);
  is @infole[0]<plugin-name>, 'mime', 'plugin name';
  is @infole[0]<plugin-type>, 'EXTRACTOR_METATYPE_MIMETYPE', 'plugin type';
  is @infole[0]<plugin-format>, 'EXTRACTOR_METAFORMAT_UTF8', 'plugin format';
  is @infole[0]<mime-type>, 'text/plain', 'mime type';
  like @infole[0]<data-type>, /text/, 'data type';
}, 'use in-process';

done-testing;
