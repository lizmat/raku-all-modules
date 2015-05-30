use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Shanghai does DateTime::TimeZone::Zone;
has %.rules = ( 
 PRC => [{:adjust("1:00"), :date("4"), :letter("D"), :month(5), :time("0:00"), :years(1986..1986)}, {:adjust("0"), :dow({:dow(7), :mindate("11")}), :letter("S"), :month(9), :time("0:00"), :years(1986..1991)}, {:adjust("1:00"), :dow({:dow(7), :mindate("10")}), :letter("D"), :month(4), :time("0:00"), :years(1987..1991)}],
 Shang => [{:adjust("1:00"), :date("3"), :letter("D"), :month(6), :time("0:00"), :years(1940..1940)}, {:adjust("0"), :date("1"), :letter("S"), :month(10), :time("0:00"), :years(1940..1941)}, {:adjust("1:00"), :date("16"), :letter("D"), :month(3), :time("0:00"), :years(1941..1941)}],
);
has @.zonedata = [{:baseoffset("8:05:57"), :rules(""), :until(-1325462400)}, {:baseoffset("8:00"), :rules("Shang"), :until(-662688000)}, {:baseoffset("8:00"), :rules("PRC"), :until(Inf)}]<>;
