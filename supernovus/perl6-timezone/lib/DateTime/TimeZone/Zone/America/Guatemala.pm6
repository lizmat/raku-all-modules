use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::Guatemala does DateTime::TimeZone::Zone;
has %.rules = ( 
 Guat => [{"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 11, "years" => 1973..1973, "date" => "25"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 2, "years" => 1974..1974, "date" => "24"}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "years" => 1983..1983, "date" => "21"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 9, "years" => 1983..1983, "date" => "22"}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 3, "years" => 1991..1991, "date" => "23"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 9, "years" => 1991..1991, "date" => "7"}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 4, "years" => 2006..2006, "date" => "30"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 10, "years" => 2006..2006, "date" => "1"}],
);
has @.zonedata = Array.new({"baseoffset" => "-6:02:04", "rules" => "", "until" => -1617062400}, {"baseoffset" => "-6:00", "rules" => "Guat", "until" => Inf});
