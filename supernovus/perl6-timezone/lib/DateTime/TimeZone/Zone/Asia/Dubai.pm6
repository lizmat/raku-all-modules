use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Dubai does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "3:41:12", "rules" => "", "until" => -1577923200}, {"baseoffset" => "4:00", "rules" => "", "until" => Inf});
