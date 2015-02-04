use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Ouagadougou does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-0:06:04", "rules" => "", "until" => -1830384000}, {"baseoffset" => "0:00", "rules" => "", "until" => Inf});
