use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Shanghai does DateTime::TimeZone::Zone;
has %.rules = ( 
 PRC => [{"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "years" => 1986..1986, "date" => "4"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 9, "dow" => {"mindate" => "11", "dow" => 7}, "years" => 1986..1991}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 4, "dow" => {"mindate" => "10", "dow" => 7}, "years" => 1987..1991}],
 Shang => [{"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 6, "years" => 1940..1940, "date" => "3"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 10, "years" => 1940..1941, "date" => "1"}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 3, "years" => 1941..1941, "date" => "16"}],
);
has @.zonedata = Array.new({"baseoffset" => "8:05:57", "rules" => "", "until" => -1325462400}, {"baseoffset" => "8:00", "rules" => "Shang", "until" => -662688000}, {"baseoffset" => "8:00", "rules" => "PRC", "until" => Inf});
