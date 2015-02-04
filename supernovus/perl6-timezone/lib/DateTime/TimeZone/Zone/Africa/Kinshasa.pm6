use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Kinshasa does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "1:01:12", "rules" => "", "until" => -2276640000}, {"baseoffset" => "1:00", "rules" => "", "until" => Inf});
