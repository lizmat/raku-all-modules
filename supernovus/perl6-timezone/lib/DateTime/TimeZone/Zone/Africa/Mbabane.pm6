use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Mbabane does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "2:04:24", "rules" => "", "until" => -2114380800}, {"baseoffset" => "2:00", "rules" => "", "until" => Inf});
