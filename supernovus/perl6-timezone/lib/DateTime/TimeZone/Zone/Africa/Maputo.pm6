use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Maputo does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "2:10:20", "rules" => "", "until" => -2114380800}, {"baseoffset" => "2:00", "rules" => "", "until" => Inf});
