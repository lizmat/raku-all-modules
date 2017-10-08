#!/usr/bin/perl6

use v6.c;

use Test;
use lib 'lib';

use-ok('Audio::OggVorbis::Ogg', 'can use Ogg.pm');
use-ok('Audio::OggVorbis::Vorbis', 'can use Vorbis.pm');
use-ok('Audio::OggVorbis::VorbisEnc', 'can use VorbisEnc.pm');

done-testing;
