use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Pyongyang does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "8:23:00", "rules" => "", "until" => -2524521600}, {"baseoffset" => "8:30", "rules" => "", "until" => -2082844800}, {"baseoffset" => "9:00", "rules" => "", "until" => -1325462400}, {"baseoffset" => "8:30", "rules" => "", "until" => -1199232000}, {"baseoffset" => "9:00", "rules" => "", "until" => -498096000}, {"baseoffset" => "8:00", "rules" => "", "until" => -264902400}, {"baseoffset" => "9:00", "rules" => "", "until" => Inf});
