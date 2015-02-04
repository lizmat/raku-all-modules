use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Makassar does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "7:57:36", "rules" => "", "until" => -1577923200}, {"baseoffset" => "7:57:36", "rules" => "", "until" => -1199232000}, {"baseoffset" => "8:00", "rules" => "", "until" => -880243200}, {"baseoffset" => "9:00", "rules" => "", "until" => -766022400}, {"baseoffset" => "8:00", "rules" => "", "until" => Inf});
