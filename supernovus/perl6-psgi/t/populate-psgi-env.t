#!/usr/bin/env perl6

use v6;

BEGIN @*INC.push: './lib';

use Test;
use PSGI;

plan(4);

sub p6sgi_version (%env, $note='p6sgi version')
{
  is %env<p6sgi.version>, Version.new('0.4.Draft'), $note;
}

sub psgi_classic_version (%env, $note='psgi classic version')
{
  is %env<psgi.version>, [1,0], $note;
}

my %p6sgi-env;

populate-psgi-env(%p6sgi-env);

p6sgi_version(%p6sgi-env);

my %psgi-classic-env;

populate-psgi-env(%psgi-classic-env, :psgi-classic, :!p6sgi);

psgi_classic_version(%psgi-classic-env);

my %combined-env;

populate-psgi-env(%combined-env, :psgi-classic);

p6sgi_version(%combined-env, 'p6sgi version in combined');
psgi_classic_version(%combined-env, 'psgi version in combined');

## TODO: more comprehensive tests.
