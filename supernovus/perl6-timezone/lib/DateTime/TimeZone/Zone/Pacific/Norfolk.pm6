use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Norfolk does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "11:11:52", "rules" => "", "until" => -2177452800}, {"baseoffset" => "11:12", "rules" => "", "until" => -599616000}, {"baseoffset" => "11:30", "rules" => "", "until" => Inf});
