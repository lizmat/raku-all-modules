#!/usr/bin/env perl6

use lib 't';
use runner;

use Test;
plan 2;

mangled 'paren', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', '🄐🄑🄒🄓🄔🄕🄖🄗🄘🄙🄚🄛🄜🄝🄞🄟🄠🄡🄢🄣🄤🄥🄦🄧🄨🄩', 'UPPERCASE';
mangled 'paren', 'abcdefghijklmnopqrstuvwxyz', '⒜⒝⒞⒟⒠⒡⒢⒣⒤⒥⒦⒧⒨⒩⒪⒫⒬⒭⒮⒯⒰⒱⒲⒳⒴⒵', 'lowercase';
