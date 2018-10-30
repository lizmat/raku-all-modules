use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Chatham does DateTime::TimeZone::Zone;
has %.rules = ( 
 Chatham => [{:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("D"), :month(11), :time("2:45s"), :years(1974..1974)}, {:adjust("0"), :lastdow(7), :letter("S"), :month(2), :time("2:45s"), :years(1975..1975)}, {:adjust("1:00"), :lastdow(7), :letter("D"), :month(10), :time("2:45s"), :years(1975..1988)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(3), :time("2:45s"), :years(1976..1989)}, {:adjust("1:00"), :dow({:dow(7), :mindate("8")}), :letter("D"), :month(10), :time("2:45s"), :years(1989..1989)}, {:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("D"), :month(10), :time("2:45s"), :years(1990..2006)}, {:adjust("0"), :dow({:dow(7), :mindate("15")}), :letter("S"), :month(3), :time("2:45s"), :years(1990..2007)}, {:adjust("1:00"), :lastdow(7), :letter("D"), :month(9), :time("2:45s"), :years(2007..Inf)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(4), :time("2:45s"), :years(2008..Inf)}],
);
has @.zonedata = [{:baseoffset("12:13:48"), :rules(""), :until(-410227200)}, {:baseoffset("12:45"), :rules("Chatham"), :until(Inf)}]<>;
