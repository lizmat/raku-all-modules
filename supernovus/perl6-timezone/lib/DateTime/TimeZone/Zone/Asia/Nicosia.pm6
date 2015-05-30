use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Nicosia does DateTime::TimeZone::Zone;
has %.rules = ( 
 Cyprus => [{:adjust("1:00"), :date("13"), :letter("S"), :month(4), :time("0:00"), :years(1975..1975)}, {:adjust("0"), :date("12"), :letter("-"), :month(10), :time("0:00"), :years(1975..1975)}, {:adjust("1:00"), :date("15"), :letter("S"), :month(5), :time("0:00"), :years(1976..1976)}, {:adjust("0"), :date("11"), :letter("-"), :month(10), :time("0:00"), :years(1976..1976)}, {:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(4), :time("0:00"), :years(1977..1980)}, {:adjust("0"), :date("25"), :letter("-"), :month(9), :time("0:00"), :years(1977..1977)}, {:adjust("0"), :date("2"), :letter("-"), :month(10), :time("0:00"), :years(1978..1978)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("0:00"), :years(1979..1997)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(3), :time("0:00"), :years(1981..1998)}],
 EUAsia => [{:adjust("1:00"), :lastdow(7), :letter("S"), :month(3), :time("1:00u"), :years(1981..Inf)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("1:00u"), :years(1979..1995)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(10), :time("1:00u"), :years(1996..Inf)}],
);
has @.zonedata = [{:baseoffset("2:13:28"), :rules(""), :until(-1518912000)}, {:baseoffset("2:00"), :rules("Cyprus"), :until(883612800)}, {:baseoffset("2:00"), :rules("EUAsia"), :until(Inf)}]<>;
