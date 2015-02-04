use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Blantyre does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "2:20:00", "rules" => "", "until" => -2114380800}, {"baseoffset" => "2:00", "rules" => "", "until" => Inf});
