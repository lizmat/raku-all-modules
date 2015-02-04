use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::HST does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-10:00", "rules" => "", "until" => Inf});
