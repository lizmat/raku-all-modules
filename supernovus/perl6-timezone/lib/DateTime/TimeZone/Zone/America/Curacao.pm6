use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::Curacao does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-4:35:47", "rules" => "", "until" => -1826755200}, {"baseoffset" => "-4:30", "rules" => "", "until" => -157766400}, {"baseoffset" => "-4:00", "rules" => "", "until" => Inf});
