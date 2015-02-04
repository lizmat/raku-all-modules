use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Bissau does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-1:02:20", "rules" => "", "until" => -1849392000}, {"baseoffset" => "-1:00", "rules" => "", "until" => 157766400}, {"baseoffset" => "0:00", "rules" => "", "until" => Inf});
