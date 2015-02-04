use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Johannesburg does DateTime::TimeZone::Zone;
has %.rules = ( 
 SA => [{"time" => "2:00", "letter" => "-", "adjust" => "1:00", "month" => 9, "dow" => {"mindate" => "15", "dow" => 7}, "years" => 1942..1943}, {"time" => "2:00", "letter" => "-", "adjust" => "0", "month" => 3, "dow" => {"mindate" => "15", "dow" => 7}, "years" => 1943..1944}],
);
has @.zonedata = Array.new({"baseoffset" => "1:52:00", "rules" => "", "until" => -2458166400}, {"baseoffset" => "1:30", "rules" => "", "until" => -2114380800}, {"baseoffset" => "2:00", "rules" => "SA", "until" => Inf});
