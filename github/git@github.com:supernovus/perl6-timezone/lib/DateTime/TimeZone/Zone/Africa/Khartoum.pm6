use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Khartoum does DateTime::TimeZone::Zone;
has %.rules = ( 
 Sudan => [{:adjust("1:00"), :date("1"), :letter("S"), :month(5), :time("0:00"), :years(1970..1970)}, {:adjust("0"), :date("15"), :letter("-"), :month(10), :time("0:00"), :years(1970..1985)}, {:adjust("1:00"), :date("30"), :letter("S"), :month(4), :time("0:00"), :years(1971..1971)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(4), :time("0:00"), :years(1972..1985)}],
);
has @.zonedata = [{:baseoffset("2:10:08"), :rules(""), :until(-1230768000)}, {:baseoffset("2:00"), :rules("Sudan"), :until(947937600)}, {:baseoffset("3:00"), :rules(""), :until(Inf)}]<>;
