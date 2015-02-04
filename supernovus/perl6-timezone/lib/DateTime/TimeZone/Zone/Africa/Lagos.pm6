use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Lagos does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "0:13:36", "rules" => "", "until" => -1609459200}, {"baseoffset" => "1:00", "rules" => "", "until" => Inf});
