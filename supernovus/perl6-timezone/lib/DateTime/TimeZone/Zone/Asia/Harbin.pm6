use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Harbin does DateTime::TimeZone::Zone;
has %.rules = ( 
 PRC => [{"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "years" => 1986..1986, "date" => "4"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 9, "dow" => {"mindate" => "11", "dow" => 7}, "years" => 1986..1991}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 4, "dow" => {"mindate" => "10", "dow" => 7}, "years" => 1987..1991}],
);
has @.zonedata = Array.new({"baseoffset" => "8:26:44", "rules" => "", "until" => -1325462400}, {"baseoffset" => "8:30", "rules" => "", "until" => -1199232000}, {"baseoffset" => "8:00", "rules" => "", "until" => -946771200}, {"baseoffset" => "9:00", "rules" => "", "until" => -126230400}, {"baseoffset" => "8:30", "rules" => "", "until" => 315532800}, {"baseoffset" => "8:00", "rules" => "PRC", "until" => Inf});
