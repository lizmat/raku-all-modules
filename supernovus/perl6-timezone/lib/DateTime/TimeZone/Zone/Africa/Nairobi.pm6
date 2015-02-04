use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Nairobi does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "2:27:16", "rules" => "", "until" => -1325462400}, {"baseoffset" => "3:00", "rules" => "", "until" => -1262304000}, {"baseoffset" => "2:30", "rules" => "", "until" => -946771200}, {"baseoffset" => "2:45", "rules" => "", "until" => -315619200}, {"baseoffset" => "3:00", "rules" => "", "until" => Inf});
