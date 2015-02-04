use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Port_Moresby does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "9:48:40", "rules" => "", "until" => -2840140800}, {"baseoffset" => "9:48:32", "rules" => "", "until" => -2366755200}, {"baseoffset" => "10:00", "rules" => "", "until" => Inf});
