use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Fiji does DateTime::TimeZone::Zone;
has %.rules = ( 
 Fiji => [{:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(11), :time("2:00"), :years(1998..1999)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(2), :time("3:00"), :years(1999..2000)}, {:adjust("1:00"), :date("29"), :letter("S"), :month(11), :time("2:00"), :years(2009..2009)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(3), :time("3:00"), :years(2010..2010)}, {:adjust("1:00"), :dow({:dow(7), :mindate("21")}), :letter("S"), :month(10), :time("2:00"), :years(2010..Inf)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("-"), :month(3), :time("3:00"), :years(2011..2011)}, {:adjust("0"), :dow({:dow(7), :mindate("18")}), :letter("-"), :month(1), :time("3:00"), :years(2012..Inf)}],
);
has @.zonedata = [{:baseoffset("11:55:44"), :rules(""), :until(-1709942400)}, {:baseoffset("12:00"), :rules("Fiji"), :until(Inf)}]<>;
