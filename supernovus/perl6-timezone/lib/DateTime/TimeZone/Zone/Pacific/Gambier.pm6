use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Gambier does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-8:59:48", "rules" => "", "until" => -1830384000}, {"baseoffset" => "-9:00", "rules" => "", "until" => Inf});
