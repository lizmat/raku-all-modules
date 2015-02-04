use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Indian::Mahe does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "3:41:48", "rules" => "", "until" => -2019686400}, {"baseoffset" => "4:00", "rules" => "", "until" => Inf});
