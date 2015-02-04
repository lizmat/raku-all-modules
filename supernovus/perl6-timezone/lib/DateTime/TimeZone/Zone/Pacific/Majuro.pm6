use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Majuro does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "11:24:48", "rules" => "", "until" => -2177452800}, {"baseoffset" => "11:00", "rules" => "", "until" => -31536000}, {"baseoffset" => "12:00", "rules" => "", "until" => Inf});
