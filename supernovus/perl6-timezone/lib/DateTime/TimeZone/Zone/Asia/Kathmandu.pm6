use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Kathmandu does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "5:41:16", "rules" => "", "until" => -1577923200}, {"baseoffset" => "5:30", "rules" => "", "until" => 504921600}, {"baseoffset" => "5:45", "rules" => "", "until" => Inf});
