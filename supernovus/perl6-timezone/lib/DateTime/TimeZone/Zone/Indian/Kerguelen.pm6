use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Indian::Kerguelen does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "0", "rules" => "", "until" => -631152000}, {"baseoffset" => "5:00", "rules" => "", "until" => Inf});
