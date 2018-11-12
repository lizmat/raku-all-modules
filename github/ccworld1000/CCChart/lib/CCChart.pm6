#!/usr/bin/env perl6
#
#  CCChart.p6
#
#  Created by CC on 2018/11/11.
#  Copyright 2018 - now youhua deng (deng you hua | CC) <ccworld1000@gmail.com>
#  https://github.com/ccworld1000/CCChart
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

unit module CCChart;

use CCLog;
use Cairo;


my Bool $isDebug = False;

my $minSizeLimt = 50;

sub pie (@values, @titles = (), @colors = (), int32 $width = 300, int32 $height = 300, Str $dst = "default.png") is export {
  unless @values {
    ccwarning 'At least to import @values';
    return -1;
  }

  unless $width > $minSizeLimt {
    ccwarning "too samll width";
    return -1;
  }

  unless $height > $minSizeLimt {
    ccwarning "too samll height";
    return -1;
  }

  say @values if $isDebug;

  my $sum = 0;

  for @values -> $item {
    $sum += $item.Int;
  }

  say $sum if $isDebug;

  my @scales = ();
  for @values -> $item {
    my $s = $item.Int / $sum;
    ccsay "$item / $sum = $s " if $isDebug ;
    @scales.append($s);
  }

  say @scales if $isDebug;

  ccsay "Begin gen Pie ......";
  given Cairo::Image.create(Cairo::FORMAT_ARGB32, $width, $height) {
    my $x = $width / 2;
    my $y = $height / 2;

    my $r = min($width, $height) /  2;

    my $conent = $_;

    given Cairo::Context.new($conent) {
      my $start = 0;
      my $step = 1;
      my $accumulation = 0;

      for @scales -> $s {
        my $percent = $s * 100;
        ccloop "$s | $percent\%" if $isDebug;

        .save();

        .new_path();
        .move_to($x, $y);

        if $step == 1 {
          .rgb(1, 0, 0);
        } else {
          if $step % 2 {
            .rgb(0, 1, 0);
          } else {
            .rgb(0, 0, 1);
          }
        }

        my $end = $s * 2 * pi;

        $accumulation += $end;
        $start = $accumulation - $end;

        ccsay "$start -> $accumulation" if $isDebug;

        .arc($x, $y, $r, $start, $accumulation);
        .close_path();

        .fill();
        .restore();

        $step += 1;
      }
    }

    .write_png($dst);
  }

  ccsay "Finish Pie";
}
