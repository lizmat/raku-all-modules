use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Galapagos does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-5:58:24", "rules" => "", "until" => -1230768000}, {"baseoffset" => "-5:00", "rules" => "", "until" => 504921600}, {"baseoffset" => "-6:00", "rules" => "", "until" => Inf});
