use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Managua does DateTime::TimeZone::Zone;
has %.rules = ( 
 Nic => [{:adjust("1:00"), :dow({:dow(7), :mindate("16")}), :letter("D"), :month(3), :time("0:00"), :years(1979..1980)}, {:adjust("0"), :dow({:dow(1), :mindate("23")}), :letter("S"), :month(6), :time("0:00"), :years(1979..1980)}, {:adjust("1:00"), :date("10"), :letter("D"), :month(4), :time("0:00"), :years(2005..2005)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(10), :time("0:00"), :years(2005..2005)}, {:adjust("1:00"), :date("30"), :letter("D"), :month(4), :time("2:00"), :years(2006..2006)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(10), :time("1:00"), :years(2006..2006)}],
);
has @.zonedata = [{:baseoffset("-5:45:08"), :rules(""), :until(-2524521600)}, {:baseoffset("-5:45:12"), :rules(""), :until(-1121126400)}, {:baseoffset("-6:00"), :rules(""), :until(94694400)}, {:baseoffset("-5:00"), :rules(""), :until(161740800)}, {:baseoffset("-6:00"), :rules("Nic"), :until(694238400)}, {:baseoffset("-5:00"), :rules(""), :until(717292800)}, {:baseoffset("-6:00"), :rules(""), :until(725846400)}, {:baseoffset("-5:00"), :rules(""), :until(852076800)}, {:baseoffset("-6:00"), :rules("Nic"), :until(Inf)}]<>;
