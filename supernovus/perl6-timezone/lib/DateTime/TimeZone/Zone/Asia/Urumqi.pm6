use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Urumqi does DateTime::TimeZone::Zone;
has %.rules = ( 
 PRC => [{"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "years" => 1986..1986, "date" => "4"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 9, "dow" => {"mindate" => "11", "dow" => 7}, "years" => 1986..1991}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 4, "dow" => {"mindate" => "10", "dow" => 7}, "years" => 1987..1991}],
);
has @.zonedata = Array.new({"baseoffset" => "5:50:20", "rules" => "", "until" => -1325462400}, {"baseoffset" => "6:00", "rules" => "", "until" => 315532800}, {"baseoffset" => "8:00", "rules" => "PRC", "until" => Inf});
