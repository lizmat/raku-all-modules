use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Dar_es_Salaam does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "2:37:08", "rules" => "", "until" => -1230768000}, {"baseoffset" => "3:00", "rules" => "", "until" => -694310400}, {"baseoffset" => "2:45", "rules" => "", "until" => -283996800}, {"baseoffset" => "3:00", "rules" => "", "until" => Inf});
