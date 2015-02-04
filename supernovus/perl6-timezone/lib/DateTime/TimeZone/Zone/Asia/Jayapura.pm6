use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Jayapura does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "9:22:48", "rules" => "", "until" => -1199232000}, {"baseoffset" => "9:00", "rules" => "", "until" => -799459200}, {"baseoffset" => "9:30", "rules" => "", "until" => -189388800}, {"baseoffset" => "9:00", "rules" => "", "until" => Inf});
