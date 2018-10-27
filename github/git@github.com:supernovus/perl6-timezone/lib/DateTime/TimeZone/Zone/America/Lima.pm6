use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Lima does DateTime::TimeZone::Zone;
has %.rules = ( 
 Peru => [{:adjust("1:00"), :date("1"), :letter("S"), :month(1), :time("0:00"), :years(1938..1938)}, {:adjust("0"), :date("1"), :letter("-"), :month(4), :time("0:00"), :years(1938..1938)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(9), :time("0:00"), :years(1938..1939)}, {:adjust("0"), :dow({:dow(7), :mindate("24")}), :letter("-"), :month(3), :time("0:00"), :years(1939..1940)}, {:adjust("1:00"), :date("1"), :letter("S"), :month(1), :time("0:00"), :years(1986..1987)}, {:adjust("0"), :date("1"), :letter("-"), :month(4), :time("0:00"), :years(1986..1987)}, {:adjust("1:00"), :date("1"), :letter("S"), :month(1), :time("0:00"), :years(1990..1990)}, {:adjust("0"), :date("1"), :letter("-"), :month(4), :time("0:00"), :years(1990..1990)}, {:adjust("1:00"), :date("1"), :letter("S"), :month(1), :time("0:00"), :years(1994..1994)}, {:adjust("0"), :date("1"), :letter("-"), :month(4), :time("0:00"), :years(1994..1994)}],
);
has @.zonedata = [{:baseoffset("-5:08:12"), :rules(""), :until(-2524521600)}, {:baseoffset("-5:08:36"), :rules(""), :until(-1938556800)}, {:baseoffset("-5:00"), :rules("Peru"), :until(Inf)}]<>;
