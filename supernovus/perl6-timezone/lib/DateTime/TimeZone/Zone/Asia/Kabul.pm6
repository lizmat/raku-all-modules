use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Kabul does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "4:36:48", "rules" => "", "until" => -2524521600}, {"baseoffset" => "4:00", "rules" => "", "until" => -788918400}, {"baseoffset" => "4:30", "rules" => "", "until" => Inf});
