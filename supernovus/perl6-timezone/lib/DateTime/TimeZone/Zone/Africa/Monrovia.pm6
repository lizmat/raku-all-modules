use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Monrovia does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-0:43:08", "rules" => "", "until" => -2776982400}, {"baseoffset" => "-0:43:08", "rules" => "", "until" => -1609459200}, {"baseoffset" => "-0:44:30", "rules" => "", "until" => 63072000}, {"baseoffset" => "0:00", "rules" => "", "until" => Inf});
