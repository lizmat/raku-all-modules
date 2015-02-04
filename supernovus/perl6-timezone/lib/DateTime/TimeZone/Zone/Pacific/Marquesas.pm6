use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Marquesas does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-9:18:00", "rules" => "", "until" => -1830384000}, {"baseoffset" => "-9:30", "rules" => "", "until" => Inf});
