#!perl6

use v6;
use lib 'lib';
use Number::Denominate;

# 2 weeks, 6 hours, 56 minutes, and 7 seconds
say denominate 1234567;

# 1 day
say denominate 23*3600 + 54*60 + 50, :1precision;

# 21 tonnes, 212 kilograms, and 121 grams
say denominate 21212121, :set<weight>;

# This script's size is 284 bytes
say "This script's size is " ~ denominate $*PROGRAM-NAME.IO.s, :set<info>;

# 4 foos, 2 boors, and 1 ber
say denominate 449, :units( foo => 3, <bar boors> => 32, 'ber' );

# {:hours(6), :minutes(56), :seconds(7), :weeks(2)}
say (denominate 1234567, :hash).perl;

# [
#   {:denomination(7),  :plural("weeks"),   :singular("week"),   :value(2) },
#   {:denomination(24), :plural("days"),    :singular("day"),    :value(0) },
#   {:denomination(60), :plural("hours"),   :singular("hour"),   :value(6) },
#   {:denomination(60), :plural("minutes"), :singular("minute"), :value(56)},
#   {:denomination(1),  :plural("seconds"), :singular("second"), :value(7) }
#]
say (denominate 1234567, :array).perl;
