use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Windhoek does DateTime::TimeZone::Zone;
has %.rules = ( 
 Namibia => [{"time" => "2:00", "letter" => "S", "adjust" => "1:00", "month" => 9, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1994..Inf}, {"time" => "2:00", "letter" => "-", "adjust" => "0", "month" => 4, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1995..Inf}],
);
has @.zonedata = Array.new({"baseoffset" => "1:08:24", "rules" => "", "until" => -2458166400}, {"baseoffset" => "1:30", "rules" => "", "until" => -2114380800}, {"baseoffset" => "2:00", "rules" => "", "until" => -860968800}, {"baseoffset" => "3:00", "rules" => "", "until" => -845244000}, {"baseoffset" => "2:00", "rules" => "", "until" => 637977600}, {"baseoffset" => "2:00", "rules" => "", "until" => 765331200}, {"baseoffset" => "1:00", "rules" => "Namibia", "until" => Inf});
