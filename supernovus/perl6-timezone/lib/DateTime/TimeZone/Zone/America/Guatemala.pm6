use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Guatemala does DateTime::TimeZone::Zone;
has %.rules = ( 
 Guat => [{:adjust("1:00"), :date("25"), :letter("D"), :month(11), :time("0:00"), :years(1973..1973)}, {:adjust("0"), :date("24"), :letter("S"), :month(2), :time("0:00"), :years(1974..1974)}, {:adjust("1:00"), :date("21"), :letter("D"), :month(5), :time("0:00"), :years(1983..1983)}, {:adjust("0"), :date("22"), :letter("S"), :month(9), :time("0:00"), :years(1983..1983)}, {:adjust("1:00"), :date("23"), :letter("D"), :month(3), :time("0:00"), :years(1991..1991)}, {:adjust("0"), :date("7"), :letter("S"), :month(9), :time("0:00"), :years(1991..1991)}, {:adjust("1:00"), :date("30"), :letter("D"), :month(4), :time("0:00"), :years(2006..2006)}, {:adjust("0"), :date("1"), :letter("S"), :month(10), :time("0:00"), :years(2006..2006)}],
);
has @.zonedata = [{:baseoffset("-6:02:04"), :rules(""), :until(-1617062400)}, {:baseoffset("-6:00"), :rules("Guat"), :until(Inf)}]<>;
