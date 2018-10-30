use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Freetown does DateTime::TimeZone::Zone;
has %.rules = ( 
 SL => [{:adjust("0:40"), :date("1"), :letter("SLST"), :month(6), :time("0:00"), :years(1935..1942)}, {:adjust("0"), :date("1"), :letter("WAT"), :month(10), :time("0:00"), :years(1935..1942)}, {:adjust("1:00"), :date("1"), :letter("SLST"), :month(6), :time("0:00"), :years(1957..1962)}, {:adjust("0"), :date("1"), :letter("GMT"), :month(9), :time("0:00"), :years(1957..1962)}],
);
has @.zonedata = [{:baseoffset("-0:53:00"), :rules(""), :until(-2776982400)}, {:baseoffset("-0:53:00"), :rules(""), :until(-1798761600)}, {:baseoffset("-1:00"), :rules("SL"), :until(-410227200)}, {:baseoffset("0:00"), :rules("SL"), :until(Inf)}]<>;
