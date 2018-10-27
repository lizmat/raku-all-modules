use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Efate does DateTime::TimeZone::Zone;
has %.rules = ( 
 Vanuatu => [{:adjust("1:00"), :date("25"), :letter("S"), :month(9), :time("0:00"), :years(1983..1983)}, {:adjust("0"), :dow({:dow(7), :mindate("23")}), :letter("-"), :month(3), :time("0:00"), :years(1984..1991)}, {:adjust("1:00"), :date("23"), :letter("S"), :month(10), :time("0:00"), :years(1984..1984)}, {:adjust("1:00"), :dow({:dow(7), :mindate("23")}), :letter("S"), :month(9), :time("0:00"), :years(1985..1991)}, {:adjust("0"), :dow({:dow(7), :mindate("23")}), :letter("-"), :month(1), :time("0:00"), :years(1992..1993)}, {:adjust("1:00"), :dow({:dow(7), :mindate("23")}), :letter("S"), :month(10), :time("0:00"), :years(1992..1992)}],
);
has @.zonedata = [{:baseoffset("11:13:16"), :rules(""), :until(-1829347200)}, {:baseoffset("11:00"), :rules("Vanuatu"), :until(Inf)}]<>;
