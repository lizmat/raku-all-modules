use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Malabo does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "0:35:08", "rules" => "", "until" => -1830384000}, {"baseoffset" => "0:00", "rules" => "", "until" => -190857600}, {"baseoffset" => "1:00", "rules" => "", "until" => Inf});
