use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Ulaanbaatar does DateTime::TimeZone::Zone;
has %.rules = ( 
 Mongol => [{:adjust("1:00"), :date("1"), :letter("S"), :month(4), :time("0:00"), :years(1983..1984)}, {:adjust("0"), :date("1"), :letter("-"), :month(10), :time("0:00"), :years(1983..1983)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(3), :time("0:00"), :years(1985..1998)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("0:00"), :years(1984..1998)}, {:adjust("1:00"), :lastdow(6), :letter("S"), :month(4), :time("2:00"), :years(2001..2001)}, {:adjust("0"), :lastdow(6), :letter("-"), :month(9), :time("2:00"), :years(2001..2006)}, {:adjust("1:00"), :lastdow(6), :letter("S"), :month(3), :time("2:00"), :years(2002..2006)}],
);
has @.zonedata = [{:baseoffset("7:07:32"), :rules(""), :until(-2051222400)}, {:baseoffset("7:00"), :rules(""), :until(252460800)}, {:baseoffset("8:00"), :rules("Mongol"), :until(Inf)}]<>;
