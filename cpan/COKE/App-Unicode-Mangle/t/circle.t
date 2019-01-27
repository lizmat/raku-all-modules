#!/usr/bin/env perl6

use lib 't';
use runner;

use Test;
plan 2;

mangled 'circle', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'ⒶⒷⒸⒹⒺⒻⒼⒽⒾⒿⓀⓁⓂⓃⓄⓅⓆⓇⓈⓉⓊⓋⓌⓍⓎⓏ', 'UPPERCASE';
mangled 'circle', 'abcdefghijklmnopqrstuvwxyz', 'ⓐⓑⓒⓓⓔⓕⓖⓗⓘⓙⓚⓛⓜⓝⓞⓟⓠⓡⓢⓣⓤⓥⓦⓧⓨⓩ', 'lowercase';
