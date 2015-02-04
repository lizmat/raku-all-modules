use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Guadalcanal does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "10:39:48", "rules" => "", "until" => -1830384000}, {"baseoffset" => "11:00", "rules" => "", "until" => Inf});
