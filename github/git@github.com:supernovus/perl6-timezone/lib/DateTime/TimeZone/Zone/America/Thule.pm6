use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Thule does DateTime::TimeZone::Zone;
has %.rules = ( 
 Thule => [{:adjust("1:00"), :lastdow(7), :letter("D"), :month(3), :time("2:00"), :years(1991..1992)}, {:adjust("0"), :lastdow(7), :letter("S"), :month(9), :time("2:00"), :years(1991..1992)}, {:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("D"), :month(4), :time("2:00"), :years(1993..2006)}, {:adjust("0"), :lastdow(7), :letter("S"), :month(10), :time("2:00"), :years(1993..2006)}, {:adjust("1:00"), :dow({:dow(7), :mindate("8")}), :letter("D"), :month(3), :time("2:00"), :years(2007..Inf)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(11), :time("2:00"), :years(2007..Inf)}],
);
has @.zonedata = [{:baseoffset("-4:35:08"), :rules(""), :until(-1686096000)}, {:baseoffset("-4:00"), :rules("Thule"), :until(Inf)}]<>;
