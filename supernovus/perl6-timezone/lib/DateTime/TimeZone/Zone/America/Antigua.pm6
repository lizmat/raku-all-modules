use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::Antigua does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-4:07:12", "rules" => "", "until" => -1825113600}, {"baseoffset" => "-5:00", "rules" => "", "until" => -599616000}, {"baseoffset" => "-4:00", "rules" => "", "until" => Inf});
