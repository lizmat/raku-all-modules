use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Baghdad does DateTime::TimeZone::Zone;
has %.rules = ( 
 Iraq => [{:adjust("1:00"), :date("1"), :letter("D"), :month(5), :time("0:00"), :years(1982..1982)}, {:adjust("0"), :date("1"), :letter("S"), :month(10), :time("0:00"), :years(1982..1984)}, {:adjust("1:00"), :date("31"), :letter("D"), :month(3), :time("0:00"), :years(1983..1983)}, {:adjust("1:00"), :date("1"), :letter("D"), :month(4), :time("0:00"), :years(1984..1985)}, {:adjust("0"), :lastdow(7), :letter("S"), :month(9), :time("1:00s"), :years(1985..1990)}, {:adjust("1:00"), :lastdow(7), :letter("D"), :month(3), :time("1:00s"), :years(1986..1990)}, {:adjust("1:00"), :date("1"), :letter("D"), :month(4), :time("3:00s"), :years(1991..2007)}, {:adjust("0"), :date("1"), :letter("S"), :month(10), :time("3:00s"), :years(1991..2007)}],
);
has @.zonedata = [{:baseoffset("2:57:40"), :rules(""), :until(-2524521600)}, {:baseoffset("2:57:36"), :rules(""), :until(-1640995200)}, {:baseoffset("3:00"), :rules(""), :until(378691200)}, {:baseoffset("3:00"), :rules("Iraq"), :until(Inf)}]<>;
