use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Australia::Brisbane does DateTime::TimeZone::Zone;
has %.rules = ( 
 AQ => [{:adjust("1:00"), :lastdow(7), :letter("-"), :month(10), :time("2:00s"), :years(1971..1971)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(2), :time("2:00s"), :years(1972..1972)}, {:adjust("1:00"), :lastdow(7), :letter("-"), :month(10), :time("2:00s"), :years(1989..1991)}, {:adjust("0"), :dow({:dow(7), :mindate("1")}), :letter("-"), :month(3), :time("2:00s"), :years(1990..1992)}],
 Aus => [{:adjust("1:00"), :date("1"), :letter("-"), :month(1), :time("0:01"), :years(1917..1917)}, {:adjust("0"), :date("25"), :letter("-"), :month(3), :time("2:00"), :years(1917..1917)}, {:adjust("1:00"), :date("1"), :letter("-"), :month(1), :time("2:00"), :years(1942..1942)}, {:adjust("0"), :date("29"), :letter("-"), :month(3), :time("2:00"), :years(1942..1942)}, {:adjust("1:00"), :date("27"), :letter("-"), :month(9), :time("2:00"), :years(1942..1942)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(3), :time("2:00"), :years(1943..1944)}, {:adjust("1:00"), :date("3"), :letter("-"), :month(10), :time("2:00"), :years(1943..1943)}],
);
has @.zonedata = [{:baseoffset("10:12:08"), :rules(""), :until(-2366755200)}, {:baseoffset("10:00"), :rules("Aus"), :until(31536000)}, {:baseoffset("10:00"), :rules("AQ"), :until(Inf)}]<>;
