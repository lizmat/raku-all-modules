use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Lome does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "0:04:52", "rules" => "", "until" => -2429827200}, {"baseoffset" => "0:00", "rules" => "", "until" => Inf});
