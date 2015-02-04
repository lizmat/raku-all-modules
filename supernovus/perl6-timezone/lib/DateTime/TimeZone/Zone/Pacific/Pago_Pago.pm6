use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Pago_Pago does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "12:37:12", "rules" => "", "until" => -2855692800}, {"baseoffset" => "-11:22:48", "rules" => "", "until" => -1861920000}, {"baseoffset" => "-11:30", "rules" => "", "until" => -631152000}, {"baseoffset" => "-11:00", "rules" => "", "until" => -94694400}, {"baseoffset" => "-11:00", "rules" => "", "until" => 438998400}, {"baseoffset" => "-11:00", "rules" => "", "until" => Inf});
