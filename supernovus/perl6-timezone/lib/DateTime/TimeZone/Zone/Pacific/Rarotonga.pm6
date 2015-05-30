use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Rarotonga does DateTime::TimeZone::Zone;
has %.rules = ( 
 Cook => [{:adjust("0:30"), :date("12"), :letter("HS"), :month(11), :time("0:00"), :years(1978..1978)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("-"), :month(3), :time("0:00"), :years(1979..1991)}, {:adjust("0:30"), :lastdow(7), :letter("HS"), :month(10), :time("0:00"), :years(1979..1990)}],
);
has @.zonedata = [{:baseoffset("-10:39:04"), :rules(""), :until(-2177452800)}, {:baseoffset("-10:30"), :rules(""), :until(279676800)}, {:baseoffset("-10:00"), :rules("Cook"), :until(Inf)}]<>;
