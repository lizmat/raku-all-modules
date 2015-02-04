use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Pohnpei does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "10:32:52", "rules" => "", "until" => -2177452800}, {"baseoffset" => "11:00", "rules" => "", "until" => Inf});
