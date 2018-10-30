use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Tegucigalpa does DateTime::TimeZone::Zone;
has %.rules = ( 
 Hond => [{:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("D"), :month(5), :time("0:00"), :years(1987..1988)}, {:adjust("0"), :lastdow(7), :letter("S"), :month(9), :time("0:00"), :years(1987..1988)}, {:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("D"), :month(5), :time("0:00"), :years(2006..2006)}, {:adjust("0"), :dow({:dow(1), :mindate("1")}), :letter("S"), :month(8), :time("0:00"), :years(2006..2006)}],
);
has @.zonedata = [{:baseoffset("-5:48:52"), :rules(""), :until(-1546300800)}, {:baseoffset("-6:00"), :rules("Hond"), :until(Inf)}]<>;
