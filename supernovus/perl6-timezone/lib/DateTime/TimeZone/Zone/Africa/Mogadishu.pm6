use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Mogadishu does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "3:01:28", "rules" => "", "until" => -2429827200}, {"baseoffset" => "3:00", "rules" => "", "until" => -1230768000}, {"baseoffset" => "2:30", "rules" => "", "until" => -410227200}, {"baseoffset" => "3:00", "rules" => "", "until" => Inf});
