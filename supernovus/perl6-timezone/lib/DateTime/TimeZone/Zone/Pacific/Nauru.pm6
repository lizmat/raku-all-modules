use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Nauru does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "11:07:40", "rules" => "", "until" => -1545091200}, {"baseoffset" => "11:30", "rules" => "", "until" => -877305600}, {"baseoffset" => "9:00", "rules" => "", "until" => -800928000}, {"baseoffset" => "11:30", "rules" => "", "until" => 283996800}, {"baseoffset" => "12:00", "rules" => "", "until" => Inf});
