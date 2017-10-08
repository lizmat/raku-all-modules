use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Chongqing does DateTime::TimeZone::Zone;
has %.rules = ( 
 PRC => [{:adjust("1:00"), :date("4"), :letter("D"), :month(5), :time("0:00"), :years(1986..1986)}, {:adjust("0"), :dow({:dow(7), :mindate("11")}), :letter("S"), :month(9), :time("0:00"), :years(1986..1991)}, {:adjust("1:00"), :dow({:dow(7), :mindate("10")}), :letter("D"), :month(4), :time("0:00"), :years(1987..1991)}],
);
has @.zonedata = [{:baseoffset("7:06:20"), :rules(""), :until(-1325462400)}, {:baseoffset("7:00"), :rules(""), :until(315532800)}, {:baseoffset("8:00"), :rules("PRC"), :until(Inf)}]<>;
