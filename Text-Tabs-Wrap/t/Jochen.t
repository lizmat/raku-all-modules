#!/usr/bin/env perl6
use v6;
use Test;
use Text::Wrap;

plan 1;

lives-ok { wrap('', '', '', :columns(1)) }, 'Edge case runs without dying';
