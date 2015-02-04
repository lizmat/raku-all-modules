use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Australia::Darwin does DateTime::TimeZone::Zone;
has %.rules = ( 
 Aus => [{"time" => "0:01", "letter" => "-", "adjust" => "1:00", "month" => 1, "years" => 1917..1917, "date" => "1"}, {"time" => "2:00", "letter" => "-", "adjust" => "0", "month" => 3, "years" => 1917..1917, "date" => "25"}, {"time" => "2:00", "letter" => "-", "adjust" => "1:00", "month" => 1, "years" => 1942..1942, "date" => "1"}, {"time" => "2:00", "letter" => "-", "adjust" => "0", "month" => 3, "years" => 1942..1942, "date" => "29"}, {"time" => "2:00", "letter" => "-", "adjust" => "1:00", "month" => 9, "years" => 1942..1942, "date" => "27"}, {"time" => "2:00", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 3, "years" => 1943..1944}, {"time" => "2:00", "letter" => "-", "adjust" => "1:00", "month" => 10, "years" => 1943..1943, "date" => "3"}],
);
has @.zonedata = Array.new({"baseoffset" => "8:43:20", "rules" => "", "until" => -2366755200}, {"baseoffset" => "9:00", "rules" => "", "until" => -2240524800}, {"baseoffset" => "9:30", "rules" => "Aus", "until" => Inf});
