use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Brazzaville does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "1:01:08", "rules" => "", "until" => -1830384000}, {"baseoffset" => "1:00", "rules" => "", "until" => Inf});
