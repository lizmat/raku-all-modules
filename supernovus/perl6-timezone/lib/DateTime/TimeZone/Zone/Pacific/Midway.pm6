use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Midway does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-11:49:28", "rules" => "", "until" => -2177452800}, {"baseoffset" => "-11:00", "rules" => "", "until" => -428544000}, {"baseoffset" => "-10:00", "rules" => "", "until" => -420681600}, {"baseoffset" => "-11:00", "rules" => "", "until" => -94694400}, {"baseoffset" => "-11:00", "rules" => "", "until" => 438998400}, {"baseoffset" => "-11:00", "rules" => "", "until" => Inf});
