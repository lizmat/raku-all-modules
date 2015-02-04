use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Khartoum does DateTime::TimeZone::Zone;
has %.rules = ( 
 Sudan => [{"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 5, "years" => 1970..1970, "date" => "1"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 10, "years" => 1970..1985, "date" => "15"}, {"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 4, "years" => 1971..1971, "date" => "30"}, {"time" => "0:00", "lastdow" => 7, "letter" => "S", "adjust" => "1:00", "month" => 4, "years" => 1972..1985}],
);
has @.zonedata = Array.new({"baseoffset" => "2:10:08", "rules" => "", "until" => -1230768000}, {"baseoffset" => "2:00", "rules" => "Sudan", "until" => 947937600}, {"baseoffset" => "3:00", "rules" => "", "until" => Inf});
