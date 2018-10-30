use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Manila does DateTime::TimeZone::Zone;
has %.rules = ( 
 Phil => [{:adjust("1:00"), :date("1"), :letter("S"), :month(11), :time("0:00"), :years(1936..1936)}, {:adjust("0"), :date("1"), :letter("-"), :month(2), :time("0:00"), :years(1937..1937)}, {:adjust("1:00"), :date("12"), :letter("S"), :month(4), :time("0:00"), :years(1954..1954)}, {:adjust("0"), :date("1"), :letter("-"), :month(7), :time("0:00"), :years(1954..1954)}, {:adjust("1:00"), :date("22"), :letter("S"), :month(3), :time("0:00"), :years(1978..1978)}, {:adjust("0"), :date("21"), :letter("-"), :month(9), :time("0:00"), :years(1978..1978)}],
);
has @.zonedata = [{:baseoffset("-15:56:00"), :rules(""), :until(-3944678400)}, {:baseoffset("8:04:00"), :rules(""), :until(-2229292800)}, {:baseoffset("8:00"), :rules("Phil"), :until(-883612800)}, {:baseoffset("9:00"), :rules(""), :until(-820540800)}, {:baseoffset("8:00"), :rules("Phil"), :until(Inf)}]<>;
