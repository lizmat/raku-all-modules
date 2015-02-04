use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Indian::Mayotte does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "3:00:56", "rules" => "", "until" => -1861920000}, {"baseoffset" => "3:00", "rules" => "", "until" => Inf});
