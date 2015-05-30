use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Indian::Mauritius does DateTime::TimeZone::Zone;
has %.rules = ( 
 Mauritius => [{:adjust("1:00"), :date("10"), :letter("S"), :month(10), :time("0:00"), :years(1982..1982)}, {:adjust("0"), :date("21"), :letter("-"), :month(3), :time("0:00"), :years(1983..1983)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(10), :time("2:00"), :years(2008..2008)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(3), :time("2:00"), :years(2009..2009)}],
);
has @.zonedata = [{:baseoffset("3:50:00"), :rules(""), :until(-1988150400)}, {:baseoffset("4:00"), :rules("Mauritius"), :until(Inf)}]<>;
