use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Ashgabat does DateTime::TimeZone::Zone;
has %.rules = ( 
 RussiaAsia => [{:adjust("1:00"), :date("1"), :letter("S"), :month(4), :time("0:00"), :years(1981..1984)}, {:adjust("0"), :date("1"), :letter("-"), :month(10), :time("0:00"), :years(1981..1983)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("2:00s"), :years(1984..1991)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(3), :time("2:00s"), :years(1985..1991)}, {:adjust("1:00"), :lastdow(6), :letter("S"), :month(3), :time("23:00"), :years(1992..1992)}, {:adjust("0"), :lastdow(6), :letter("-"), :month(9), :time("23:00"), :years(1992..1992)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(3), :time("2:00s"), :years(1993..Inf)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(9), :time("2:00s"), :years(1993..1995)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(10), :time("2:00s"), :years(1996..Inf)}],
);
has @.zonedata = [{:baseoffset("3:53:32"), :rules(""), :until(-1441152000)}, {:baseoffset("4:00"), :rules(""), :until(-1247529600)}, {:baseoffset("5:00"), :rules("RussiaAsia"), :until(670384800)}, {:baseoffset("4:00"), :rules("RussiaAsia"), :until(688521600)}, {:baseoffset("4:00"), :rules("RussiaAsia"), :until(695786400)}, {:baseoffset("5:00"), :rules(""), :until(Inf)}]<>;
