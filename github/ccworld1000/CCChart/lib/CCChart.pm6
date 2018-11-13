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

# create coordinate line
sub createCoordinateLine (Cairo::Context $c, $width, $height) {
  next unless $c;

  my $offset = 1;
  my @cs = (($offset, $offset), ($offset, $height), ($width, $height));
  loop (my $step = 0; $step < @cs.elems; $step++) {
    next if $step > 1;

    my ($firstX, $firstY) = @cs[$step];
    my ($secondX, $secondY) = @cs[$step+1];

    ccloop "first : ($firstX, $firstY), second ($secondX, $secondY)" if $isDebug;

    $c.move_to($firstX, $firstY);
    $c.line_to($secondX, $secondY);
  }
}

sub lines (@values, int32 $width = 300, int32 $height = 300, Str $dst = "default_lines.png") is export {
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

  given Cairo::Image.create(Cairo::FORMAT_ARGB32, $width, $height) {
    ccsay "Begin gen lines ......";
    given Cairo::Context.new($_) {
      .rgb(0, 0, 1);

      createCoordinateLine($_, $width, $height);

      .line_width = 2.0;
      .line_cap = Cairo::LINE_CAP_ROUND;

      my $max = -1;
      for @values -> $item {
        if $item > $max {
          $max = $item;
        }
      }

      unless $max > 0 {
        ccwarning "ill max value";
        return -1;
      }

      say "Max $max" if $isDebug;

      my @xyList = ();
      my $count = @values.elems;
      my $index = 1;
      for @values -> $item {
        my $s = $item.Int / $max;

        my $x = $index * ($width / ($count + 1));
        my $y = (1 - $s) * $height;

        @xyList.push(($x, $y));
        $index++;
      }

      $count = @xyList.elems;

      $index = 1;

      if $count > 1 {
        for (@xyList) -> ($x, $y) {
          next if ($count - 1) == $index;

          ccloop "move to($x, $y)" if $isDebug;
          .move_to($x, $y);

          my ($sX, $sY) = @xyList[$index];

          .line_to($sX, $sY);

          $index++;
        }
      } else {
        ccwarning "Array elements are at least 2.";
      }

      .stroke;
    }

    .write_png($dst);
  }

  ccsay "Finish lines";
}
