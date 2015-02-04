use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Guam does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-14:21:00", "rules" => "", "until" => -3944678400}, {"baseoffset" => "9:39:00", "rules" => "", "until" => -2177452800}, {"baseoffset" => "10:00", "rules" => "", "until" => 977529600}, {"baseoffset" => "10:00", "rules" => "", "until" => Inf});
