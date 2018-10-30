use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Johannesburg does DateTime::TimeZone::Zone;
has %.rules = ( 
 SA => [{:adjust("1:00"), :dow({:dow(7), :mindate("15")}), :letter("-"), :month(9), :time("2:00"), :years(1942..1943)}, {:adjust("0"), :dow({:dow(7), :mindate("15")}), :letter("-"), :month(3), :time("2:00"), :years(1943..1944)}],
);
has @.zonedata = [{:baseoffset("1:52:00"), :rules(""), :until(-2458166400)}, {:baseoffset("1:30"), :rules(""), :until(-2114380800)}, {:baseoffset("2:00"), :rules("SA"), :until(Inf)}]<>;
