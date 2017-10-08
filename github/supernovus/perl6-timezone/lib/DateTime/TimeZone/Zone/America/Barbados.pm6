use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Barbados does DateTime::TimeZone::Zone;
has %.rules = ( 
 Barb => [{:adjust("1:00"), :date("12"), :letter("D"), :month(6), :time("2:00"), :years(1977..1977)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(10), :time("2:00"), :years(1977..1978)}, {:adjust("1:00"), :dow({:dow(7), :mindate("15")}), :letter("D"), :month(4), :time("2:00"), :years(1978..1980)}, {:adjust("0"), :date("30"), :letter("S"), :month(9), :time("2:00"), :years(1979..1979)}, {:adjust("0"), :date("25"), :letter("S"), :month(9), :time("2:00"), :years(1980..1980)}],
);
has @.zonedata = [{:baseoffset("-3:58:29"), :rules(""), :until(-1451692800)}, {:baseoffset("-3:58:29"), :rules(""), :until(-1199232000)}, {:baseoffset("-4:00"), :rules("Barb"), :until(Inf)}]<>;
