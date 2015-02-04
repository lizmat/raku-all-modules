use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Tokyo does DateTime::TimeZone::Zone;
has %.rules = ( 
 Japan => [{"time" => "2:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1948..1948}, {"time" => "2:00", "letter" => "S", "adjust" => "0", "month" => 9, "dow" => {"mindate" => "8", "dow" => 6}, "years" => 1948..1951}, {"time" => "2:00", "letter" => "D", "adjust" => "1:00", "month" => 4, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1949..1949}, {"time" => "2:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1950..1951}],
);
has @.zonedata = Array.new({"baseoffset" => "9:18:59", "rules" => "", "until" => -2587712400}, {"baseoffset" => "9:00", "rules" => "", "until" => -2335219200}, {"baseoffset" => "9:00", "rules" => "", "until" => -1009843200}, {"baseoffset" => "9:00", "rules" => "Japan", "until" => Inf});
