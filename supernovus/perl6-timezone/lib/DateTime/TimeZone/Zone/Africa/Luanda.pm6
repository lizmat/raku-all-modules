use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Luanda does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "0:52:56", "rules" => "", "until" => -2461449600}, {"baseoffset" => "0:52:04", "rules" => "", "until" => -1849392000}, {"baseoffset" => "1:00", "rules" => "", "until" => Inf});
