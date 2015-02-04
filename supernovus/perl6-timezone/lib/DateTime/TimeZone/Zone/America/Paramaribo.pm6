use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::Paramaribo does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-3:40:40", "rules" => "", "until" => -1861920000}, {"baseoffset" => "-3:40:52", "rules" => "", "until" => -1104537600}, {"baseoffset" => "-3:40:36", "rules" => "", "until" => -788918400}, {"baseoffset" => "-3:30", "rules" => "", "until" => 185673600}, {"baseoffset" => "-3:30", "rules" => "", "until" => 441763200}, {"baseoffset" => "-3:00", "rules" => "", "until" => Inf});
