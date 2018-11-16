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


unit module CCColor;

constant $CCColorErrorIllString = "Error: ill hex string";
constant $CCColorValue255       = 255.0;
constant $CCColorValueFF        = '0xFF';

my Bool $CCColorIsDebug = False;

sub checkIsValidHex (Str $c) {
  my Bool $ret = False;

  return $ret unless $c;
  return $ret unless $c.elems == 1;

  $ret = True;

  if $c ~~ /<[a .. z A .. Z]>/ {
    my $cmp = $c cmp "F";

    if $cmp === More {
      say "$CCColorErrorIllString (-- $c --)" if $CCColorIsDebug;
      $ret = False;
    }
  }

  return $ret
}

sub checkMultipleCharactersAreValidHex (Str $cc) {
  my Bool $ret = False;

  return $ret unless $cc;

  $ret = True;

  my $count = $cc.chars;
  loop (my $index = 0; $index < $count; $index++) {
    my $c = $cc.substr($index, 1);
    $ret = checkIsValidHex($c);

    last unless $ret;
  }

  return $ret;
}

sub hex2rgba (Str $hex) is export {
  # if error use 0
  # But it will output error messages.
  my ($r, $g, $b, $a) = 0, 0, 0, 0;

  # fixed
  my $zeroString = '0';
  my @rgba = $zeroString, $zeroString, $zeroString, $CCColorValueFF;
  # my @rgba = "0", "0", "0", "0";

  say $CCColorErrorIllString unless $hex;

  #ignore # \s
  my $innerHex = $hex.trim;
  $innerHex = $innerHex.subst(/"#"/, "", :g);
  $innerHex = $innerHex.subst(/\s/, "", :g);

  my $count = $innerHex.chars;
  say "count = $count" if $CCColorIsDebug;

  my @values = ();

  my $step = 0;
  if $count {
    given $count {
      when 1..4 {
        # 4 limit
        loop (my $index = 0; $index < @rgba.elems; $index++) {
          if $index < $count {
            my $c = $innerHex.substr($index, 1);
            # say $c;

            last unless checkIsValidHex($c);

             @rgba[$index] = "0x$c";
          }
        }
      }

      when 5 .. * {
        my $maxCount = @rgba.elems;
        my $hanldeCount = ceiling($count / 2.0);

        $maxCount = $hanldeCount < $maxCount ??  $hanldeCount !! $maxCount;

        loop (my $index = 0; $index < $maxCount ; $index++ ) {
            my $cc = $innerHex.substr($step, 2);
            say "CC STEP $step : $cc" if $CCColorIsDebug;
            last unless checkMultipleCharactersAreValidHex($cc);
             @rgba[$index] = "0x$cc";

             $step += 2;
        }
      }

      default {
        say 'ignore';
      }
    }
  } else {
    say $CCColorErrorIllString;
  }

  for @rgba -> $item {
    my $value = $item.Int / $CCColorValue255;
    @values.push($value);
  }

  if @values.elems == 4 {
    ($r, $g, $b, $a) = @values;
  }

  return ($r, $g, $b, $a);
}
