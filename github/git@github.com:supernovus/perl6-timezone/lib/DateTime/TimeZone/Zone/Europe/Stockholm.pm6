use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Europe::Stockholm does DateTime::TimeZone::Zone;
has %.rules = ( 
 EU => [{:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(4), :time("1:00u"), :years(1977..1980)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("1:00u"), :years(1977..1977)}, {:adjust("0"), :date("1"), :letter("-"), :month(10), :time("1:00u"), :years(1978..1978)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("1:00u"), :years(1979..1995)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(3), :time("1:00u"), :years(1981..Inf)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(10), :time("1:00u"), :years(1996..Inf)}],
);
has @.zonedata = [{:baseoffset("1:12:12"), :rules(""), :until(-2871676800)}, {:baseoffset("1:00:14"), :rules(""), :until(-2208988800)}, {:baseoffset("1:00"), :rules(""), :until(-1692493200)}, {:baseoffset("2:00"), :rules(""), :until(-1680476400)}, {:baseoffset("1:00"), :rules(""), :until(315532800)}, {:baseoffset("1:00"), :rules("EU"), :until(Inf)}]<>;
