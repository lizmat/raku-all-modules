#!/usr/bin/env perl6
#
#  CCColor.pm6
#
#  Created by CC on 2018/11/15.
#  Copyright 2018 - now youhua deng (deng you hua | CC) <ccworld1000@gmail.com>
#  https://github.com/ccworld1000/CCColor
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#


use CCColor;

my @list =
(
"   #FFFEA963 ",
"   #FF FE A9 63 ",
"   #FF # FE #   A9 #     63 ",
"   #",
"   #1",
"   #123",
"   #FFH",
"   #FHF",
"   #1234",
"   #12345",
"   #FFEE5",
"   #FFEE56",
"   #FFEE56A",
"   #FFEE56AH",
"   #FFEE56AA",
"   #FFEE56AA11",
"   #FFEE56AAFF11",
);

for @list -> $color {
  my ($r, $g, $b, $a) = hex2rgba($color);
  say "$r, $g, $b, $a";
}
