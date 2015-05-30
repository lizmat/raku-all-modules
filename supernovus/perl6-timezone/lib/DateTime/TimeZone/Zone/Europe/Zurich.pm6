use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Europe::Zurich does DateTime::TimeZone::Zone;
has %.rules = ( 
 EU => [{:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(4), :time("1:00u"), :years(1977..1980)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("1:00u"), :years(1977..1977)}, {:adjust("0"), :date("1"), :letter("-"), :month(10), :time("1:00u"), :years(1978..1978)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("1:00u"), :years(1979..1995)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(3), :time("1:00u"), :years(1981..Inf)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(10), :time("1:00u"), :years(1996..Inf)}],
 Swiss => [{:adjust("1:00"), :dow({:dow(1), :mindate("1")}), :letter("S"), :month(5), :time("1:00"), :years(1941..1942)}, {:adjust("0"), :dow({:dow(1), :mindate("1")}), :letter("-"), :month(10), :time("2:00"), :years(1941..1942)}],
);
has @.zonedata = [{:baseoffset("0:34:08"), :rules(""), :until(-3675196800)}, {:baseoffset("0:29:46"), :rules(""), :until(-2398291200)}, {:baseoffset("1:00"), :rules("Swiss"), :until(347155200)}, {:baseoffset("1:00"), :rules("EU"), :until(Inf)}]<>;
