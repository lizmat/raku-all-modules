use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Noumea does DateTime::TimeZone::Zone;
has %.rules = ( 
 NC => [{:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(12), :time("0:00"), :years(1977..1978)}, {:adjust("0"), :date("27"), :letter("-"), :month(2), :time("0:00"), :years(1978..1979)}, {:adjust("1:00"), :date("1"), :letter("S"), :month(12), :time("2:00s"), :years(1996..1996)}, {:adjust("0"), :date("2"), :letter("-"), :month(3), :time("2:00s"), :years(1997..1997)}],
);
has @.zonedata = [{:baseoffset("11:05:48"), :rules(""), :until(-1829347200)}, {:baseoffset("11:00"), :rules("NC"), :until(Inf)}]<>;
