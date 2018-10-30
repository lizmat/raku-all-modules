use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Europe::Helsinki does DateTime::TimeZone::Zone;
has %.rules = ( 
 EU => [{:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(4), :time("1:00u"), :years(1977..1980)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("1:00u"), :years(1977..1977)}, {:adjust("0"), :date("1"), :letter("-"), :month(10), :time("1:00u"), :years(1978..1978)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("1:00u"), :years(1979..1995)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(3), :time("1:00u"), :years(1981..Inf)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(10), :time("1:00u"), :years(1996..Inf)}],
 Finland => [{:adjust("1:00"), :date("3"), :letter("S"), :month(4), :time("0:00"), :years(1942..1942)}, {:adjust("0"), :date("3"), :letter("-"), :month(10), :time("0:00"), :years(1942..1942)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(3), :time("2:00"), :years(1981..1982)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("3:00"), :years(1981..1982)}],
);
has @.zonedata = [{:baseoffset("1:39:52"), :rules(""), :until(-2890252800)}, {:baseoffset("1:39:52"), :rules(""), :until(-1546300800)}, {:baseoffset("2:00"), :rules("Finland"), :until(410227200)}, {:baseoffset("2:00"), :rules("EU"), :until(Inf)}]<>;
