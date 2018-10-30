use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Costa_Rica does DateTime::TimeZone::Zone;
has %.rules = ( 
 CR => [{:adjust("1:00"), :lastdow(7), :letter("D"), :month(2), :time("0:00"), :years(1979..1980)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(6), :time("0:00"), :years(1979..1980)}, {:adjust("1:00"), :dow({:dow(6), :mindate("15")}), :letter("D"), :month(1), :time("0:00"), :years(1991..1992)}, {:adjust("0"), :date("1"), :letter("S"), :month(7), :time("0:00"), :years(1991..1991)}, {:adjust("0"), :date("15"), :letter("S"), :month(3), :time("0:00"), :years(1992..1992)}],
);
has @.zonedata = [{:baseoffset("-5:36:13"), :rules(""), :until(-2524521600)}, {:baseoffset("-5:36:13"), :rules(""), :until(-1545091200)}, {:baseoffset("-6:00"), :rules("CR"), :until(Inf)}]<>;
