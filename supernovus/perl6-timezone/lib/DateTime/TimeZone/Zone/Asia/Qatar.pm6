use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Qatar does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "3:26:08", "rules" => "", "until" => -1577923200}, {"baseoffset" => "4:00", "rules" => "", "until" => 63072000}, {"baseoffset" => "3:00", "rules" => "", "until" => Inf});
