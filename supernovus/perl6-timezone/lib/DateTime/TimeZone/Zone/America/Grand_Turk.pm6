use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Grand_Turk does DateTime::TimeZone::Zone;
has %.rules = ( 
 TC => [{:adjust("1:00"), :lastdow(7), :letter("D"), :month(4), :time("2:00"), :years(1979..1986)}, {:adjust("0"), :lastdow(7), :letter("S"), :month(10), :time("2:00"), :years(1979..2006)}, {:adjust("1:00"), :dow({:dow(7), :mindate("1")}), :letter("D"), :month(4), :time("2:00"), :years(1987..2006)}, {:adjust("1:00"), :dow({:dow(7), :mindate("8")}), :letter("D"), :month(3), :time("2:00"), :years(2007..Inf)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("S"), :month(11), :time("2:00"), :years(2007..Inf)}],
);
has @.zonedata = [{:baseoffset("-4:44:32"), :rules(""), :until(-2524521600)}, {:baseoffset("-5:07:11"), :rules(""), :until(-1830384000)}, {:baseoffset("-5:00"), :rules("TC"), :until(Inf)}]<>;
