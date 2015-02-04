use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::Panama does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-5:18:08", "rules" => "", "until" => -2524521600}, {"baseoffset" => "-5:19:36", "rules" => "", "until" => -1946937600}, {"baseoffset" => "-5:00", "rules" => "", "until" => Inf});
