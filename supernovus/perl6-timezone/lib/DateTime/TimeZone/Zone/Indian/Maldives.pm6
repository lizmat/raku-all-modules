use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Indian::Maldives does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "4:54:00", "rules" => "", "until" => -2840140800}, {"baseoffset" => "4:54:00", "rules" => "", "until" => -315619200}, {"baseoffset" => "5:00", "rules" => "", "until" => Inf});
