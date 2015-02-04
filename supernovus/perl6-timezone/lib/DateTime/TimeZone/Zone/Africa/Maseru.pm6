use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Maseru does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "1:50:00", "rules" => "", "until" => -2114380800}, {"baseoffset" => "2:00", "rules" => "", "until" => -829519200}, {"baseoffset" => "3:00", "rules" => "", "until" => -813794400}, {"baseoffset" => "2:00", "rules" => "", "until" => Inf});
