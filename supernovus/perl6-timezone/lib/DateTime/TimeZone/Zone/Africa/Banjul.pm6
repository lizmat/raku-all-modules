use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Banjul does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-1:06:36", "rules" => "", "until" => -1830384000}, {"baseoffset" => "-1:06:36", "rules" => "", "until" => -1104537600}, {"baseoffset" => "-1:00", "rules" => "", "until" => -189388800}, {"baseoffset" => "0:00", "rules" => "", "until" => Inf});
