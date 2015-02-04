use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Chuuk does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "10:07:08", "rules" => "", "until" => -2177452800}, {"baseoffset" => "10:00", "rules" => "", "until" => Inf});
