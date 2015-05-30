use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Seoul does DateTime::TimeZone::Zone;
has %.rules = ( 
 ROK => [{:adjust("1:00"), :date("15"), :letter("D"), :month(5), :time("0:00"), :years(1960..1960)}, {:adjust("0"), :date("13"), :letter("S"), :month(9), :time("0:00"), :years(1960..1960)}, {:adjust("1:00"), :dow({:dow(7), :mindate("8")}), :letter("D"), :month(5), :time("0:00"), :years(1987..1988)}, {:adjust("0"), :dow({:dow(7), :mindate("8")}), :letter("S"), :month(10), :time("0:00"), :years(1987..1988)}],
);
has @.zonedata = [{:baseoffset("8:27:52"), :rules(""), :until(-2524521600)}, {:baseoffset("8:30"), :rules(""), :until(-2082844800)}, {:baseoffset("9:00"), :rules(""), :until(-1325462400)}, {:baseoffset("8:30"), :rules(""), :until(-1199232000)}, {:baseoffset("9:00"), :rules(""), :until(-498096000)}, {:baseoffset("8:00"), :rules("ROK"), :until(-264902400)}, {:baseoffset("8:30"), :rules(""), :until(-63158400)}, {:baseoffset("9:00"), :rules("ROK"), :until(Inf)}]<>;
