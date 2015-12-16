# t/ordinal-digit.t -- test &ordinal_digit
use v6;
use Test;
use Lingua::EN::Numbers::Ordinal;

plan *;

# single digits
is ordinal_digit(0), "0th", "0 is 0th";
is ordinal_digit(1), "1st", "1 is 1st";
is ordinal_digit(2), "2nd", "2 is 2nd";
is ordinal_digit(3), "3rd", "3 is 3rd";
is ordinal_digit(4), "4th", "4 is 4th";
is ordinal_digit(5), "5th", "5 is 5th";
is ordinal_digit(6), "6th", "6 is 6th";
is ordinal_digit(7), "7th", "7 is 7th";
is ordinal_digit(8), "8th", "8 is 8th";
is ordinal_digit(9), "9th", "9 is 9th";

# teens (always th)
is ordinal_digit(10), "10th", "10 is 10th";
is ordinal_digit(11), "11th", "11 is 11th";
is ordinal_digit(12), "12th", "12 is 12th";
is ordinal_digit(13), "13th", "13 is 13th";
is ordinal_digit(14), "14th", "14 is 14th";
is ordinal_digit(15), "15th", "15 is 15th";
is ordinal_digit(16), "16th", "16 is 16th";
is ordinal_digit(17), "17th", "17 is 17th";
is ordinal_digit(18), "18th", "18 is 18th";
is ordinal_digit(19), "19th", "19 is 19th";

# test some other numbers under 100
is ordinal_digit(20), "20th", "20 is 20th";
is ordinal_digit(21), "21st", "21 is 21st";
is ordinal_digit(30), "30th", "30 is 30th";
is ordinal_digit(32), "32nd", "32 is 32nd";
is ordinal_digit(40), "40th", "40 is 40th";
is ordinal_digit(43), "43rd", "43 is 43rd";
is ordinal_digit(50), "50th", "50 is 50th";
is ordinal_digit(54), "54th", "54 is 54th";
is ordinal_digit(60), "60th", "60 is 60th";
is ordinal_digit(65), "65th", "65 is 65th";
is ordinal_digit(70), "70th", "70 is 70th";
is ordinal_digit(76), "76th", "76 is 76th";
is ordinal_digit(80), "80th", "80 is 80th";
is ordinal_digit(87), "87th", "87 is 87th";
is ordinal_digit(90), "90th", "90 is 90th";
is ordinal_digit(98), "98th", "98 is 98th";
is ordinal_digit(99), "99th", "99 is 99th";

# some hundreds
is ordinal_digit(100), "100th", "100 is 100th";
is ordinal_digit(101), "101st", "101 is 101st";
is ordinal_digit(102), "102nd", "102 is 102nd";
is ordinal_digit(103), "103rd", "103 is 103rd";
is ordinal_digit(104), "104th", "104 is 104th";
is ordinal_digit(105), "105th", "105 is 105th";
is ordinal_digit(106), "106th", "106 is 106th";
is ordinal_digit(107), "107th", "107 is 107th";
is ordinal_digit(108), "108th", "108 is 108th";
is ordinal_digit(109), "109th", "109 is 109th";

is ordinal_digit(110), "110th", "110 is 110th";
is ordinal_digit(111), "111th", "111 is 111th";
is ordinal_digit(112), "112th", "112 is 112th";
is ordinal_digit(113), "113th", "113 is 113th";
is ordinal_digit(114), "114th", "114 is 114th";

# does it work on 1 googol?
my $googol = ('1' ~ ('0' xx 100).join).Int;

ok ordinal_digit($googol), "Can process 1 googol";

# I'm *not* outputting the whole number in the message!
is ordinal_digit($googol), "{$googol}th", "1 googol is 1 googol-th";

done-testing;
