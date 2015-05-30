use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Karachi does DateTime::TimeZone::Zone;
has %.rules = ( 
 Pakistan => [{:adjust("1:00"), :dow({:dow(7), :mindate("2")}), :letter("S"), :month(4), :time("0:01"), :years(2002..2002)}, {:adjust("0"), :dow({:dow(7), :mindate("2")}), :letter("-"), :month(10), :time("0:01"), :years(2002..2002)}, {:adjust("1:00"), :date("1"), :letter("S"), :month(6), :time("0:00"), :years(2008..2008)}, {:adjust("0"), :date("1"), :letter("-"), :month(11), :time("0:00"), :years(2008..2008)}, {:adjust("1:00"), :date("15"), :letter("S"), :month(4), :time("0:00"), :years(2009..2009)}, {:adjust("0"), :date("1"), :letter("-"), :month(11), :time("0:00"), :years(2009..2009)}],
);
has @.zonedata = [{:baseoffset("4:28:12"), :rules(""), :until(-1988150400)}, {:baseoffset("5:30"), :rules(""), :until(-883612800)}, {:baseoffset("6:30"), :rules(""), :until(-764121600)}, {:baseoffset("5:30"), :rules(""), :until(-576115200)}, {:baseoffset("5:00"), :rules(""), :until(38793600)}, {:baseoffset("5:00"), :rules("Pakistan"), :until(Inf)}]<>;
