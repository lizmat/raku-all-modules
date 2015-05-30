use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Port_minus_au_minus_Prince does DateTime::TimeZone::Zone;
has %.rules = ( 
 Haiti => [{:adjust("1:00"), :date("8"), :letter("D"), :month(5), :time("0:00"), :years(1983..1983)}, {:adjust("1:00"), :lastdow(7), :letter("D"), :month(4), :time("0:00"), :years(1984..1987)}, {:adjust("0"), :lastdow(7), :letter("S"), :month(10), :time("0:00"), :years(1983..1987)}, {:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("D"), :month(4), :time("1:00s"), :years(1988..1997)}, {:adjust("0"), :lastdow(7), :letter("S"), :month(10), :time("1:00s"), :years(1988..1997)}, {:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("D"), :month(4), :time("0:00"), :years(2005..2006)}, {:adjust("0"), :lastdow(7), :letter("S"), :month(10), :time("0:00"), :years(2005..2006)}, {:adjust("1:00"), :dow({:dow(7), :mindate("8")}), :letter("D"), :month(3), :time("2:00"), :years(2012..Inf)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(11), :time("2:00"), :years(2012..Inf)}],
);
has @.zonedata = [{:baseoffset("-4:49:20"), :rules(""), :until(-2524521600)}, {:baseoffset("-4:49"), :rules(""), :until(-1670500800)}, {:baseoffset("-5:00"), :rules("Haiti"), :until(Inf)}]<>;
