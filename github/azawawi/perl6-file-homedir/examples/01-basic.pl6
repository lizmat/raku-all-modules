#!/usr/bin/env perl6

use v6;

use lib 'lib';
use File::HomeDir;

say File::HomeDir.my-home;
say File::HomeDir.my-desktop;
say File::HomeDir.my-documents;
say File::HomeDir.my-pictures;
say File::HomeDir.my-videos;
