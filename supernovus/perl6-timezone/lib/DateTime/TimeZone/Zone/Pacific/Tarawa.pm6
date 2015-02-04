use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Tarawa does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "11:32:04", "rules" => "", "until" => -2177452800}, {"baseoffset" => "12:00", "rules" => "", "until" => Inf});
