use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Belize does DateTime::TimeZone::Zone;
has %.rules = ( 
 Belize => [{:adjust("0:30"), :dow({:dow(7), :mindate("2")}), :letter("HD"), :month(10), :time("0:00"), :years(1918..1942)}, {:adjust("0"), :dow({:dow(7), :mindate("9")}), :letter("S"), :month(2), :time("0:00"), :years(1919..1943)}, {:adjust("1:00"), :date("5"), :letter("D"), :month(12), :time("0:00"), :years(1973..1973)}, {:adjust("0"), :date("9"), :letter("S"), :month(2), :time("0:00"), :years(1974..1974)}, {:adjust("1:00"), :date("18"), :letter("D"), :month(12), :time("0:00"), :years(1982..1982)}, {:adjust("0"), :date("12"), :letter("S"), :month(2), :time("0:00"), :years(1983..1983)}],
);
has @.zonedata = [{:baseoffset("-5:52:48"), :rules(""), :until(-1830384000)}, {:baseoffset("-6:00"), :rules("Belize"), :until(Inf)}]<>;
