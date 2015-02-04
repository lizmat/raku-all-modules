use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Antarctica::Rothera does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "0", "rules" => "", "until" => 218246400}, {"baseoffset" => "-3:00", "rules" => "", "until" => Inf});
