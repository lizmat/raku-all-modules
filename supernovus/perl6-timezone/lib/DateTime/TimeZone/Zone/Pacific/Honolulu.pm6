use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Honolulu does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "-10:31:26", "rules" => "", "until" => -2334139200}, {"baseoffset" => "-10:30", "rules" => "", "until" => -1157320800}, {"baseoffset" => "-9:30", "rules" => "", "until" => -1155470400}, {"baseoffset" => "-10:30", "rules" => "", "until" => -880236000}, {"baseoffset" => "-9:30", "rules" => "", "until" => -765410400}, {"baseoffset" => "-10:30", "rules" => "", "until" => -712188000}, {"baseoffset" => "-10:00", "rules" => "", "until" => Inf});
