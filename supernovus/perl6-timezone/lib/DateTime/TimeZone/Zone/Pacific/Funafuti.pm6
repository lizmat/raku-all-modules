use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Funafuti does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "11:56:52", "rules" => "", "until" => -2177452800}, {"baseoffset" => "12:00", "rules" => "", "until" => Inf});
