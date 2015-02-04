use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Europe::Helsinki does DateTime::TimeZone::Zone;
has %.rules = ( 
 EU => [{"time" => "1:00u", "letter" => "S", "adjust" => "1:00", "month" => 4, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1977..1980}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 9, "years" => 1977..1977}, {"time" => "1:00u", "letter" => "-", "adjust" => "0", "month" => 10, "years" => 1978..1978, "date" => "1"}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 9, "years" => 1979..1995}, {"time" => "1:00u", "lastdow" => 7, "letter" => "S", "adjust" => "1:00", "month" => 3, "years" => 1981..Inf}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 10, "years" => 1996..Inf}],
 Finland => [{"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 4, "years" => 1942..1942, "date" => "3"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 10, "years" => 1942..1942, "date" => "3"}, {"time" => "2:00", "lastdow" => 7, "letter" => "S", "adjust" => "1:00", "month" => 3, "years" => 1981..1982}, {"time" => "3:00", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 9, "years" => 1981..1982}],
);
has @.zonedata = Array.new({"baseoffset" => "1:39:52", "rules" => "", "until" => -2890252800}, {"baseoffset" => "1:39:52", "rules" => "", "until" => -1546300800}, {"baseoffset" => "2:00", "rules" => "Finland", "until" => 410227200}, {"baseoffset" => "2:00", "rules" => "EU", "until" => Inf});
