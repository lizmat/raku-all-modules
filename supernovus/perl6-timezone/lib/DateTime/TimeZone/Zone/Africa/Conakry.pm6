use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Conakry does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-0:54:52", "rules" => "", "until" => -1830384000}, {"baseoffset" => "0:00", "rules" => "", "until" => -1131235200}, {"baseoffset" => "-1:00", "rules" => "", "until" => -315619200}, {"baseoffset" => "0:00", "rules" => "", "until" => Inf});
