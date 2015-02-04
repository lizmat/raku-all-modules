use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Dakar does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-1:09:44", "rules" => "", "until" => -1830384000}, {"baseoffset" => "-1:00", "rules" => "", "until" => -915148800}, {"baseoffset" => "0:00", "rules" => "", "until" => Inf});
