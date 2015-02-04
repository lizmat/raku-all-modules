use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Riyadh does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "3:06:52", "rules" => "", "until" => -631152000}, {"baseoffset" => "3:00", "rules" => "", "until" => Inf});
