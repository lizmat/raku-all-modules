use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Porto_minus_Novo does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "0:10:28", "rules" => "", "until" => -1830384000}, {"baseoffset" => "0:00", "rules" => "", "until" => -1131235200}, {"baseoffset" => "1:00", "rules" => "", "until" => Inf});
