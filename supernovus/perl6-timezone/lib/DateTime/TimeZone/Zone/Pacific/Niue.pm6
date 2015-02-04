use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Niue does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-11:19:40", "rules" => "", "until" => -2177452800}, {"baseoffset" => "-11:20", "rules" => "", "until" => -599616000}, {"baseoffset" => "-11:30", "rules" => "", "until" => 276048000}, {"baseoffset" => "-11:00", "rules" => "", "until" => Inf});
