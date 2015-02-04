use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Kiritimati does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-10:29:20", "rules" => "", "until" => -2177452800}, {"baseoffset" => "-10:40", "rules" => "", "until" => 283996800}, {"baseoffset" => "-10:00", "rules" => "", "until" => 788918400}, {"baseoffset" => "14:00", "rules" => "", "until" => Inf});
