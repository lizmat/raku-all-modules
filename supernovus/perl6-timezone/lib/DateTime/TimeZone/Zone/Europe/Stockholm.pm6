use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Europe::Stockholm does DateTime::TimeZone::Zone;
has %.rules = ( 
 EU => [{"time" => "1:00u", "letter" => "S", "adjust" => "1:00", "month" => 4, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1977..1980}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 9, "years" => 1977..1977}, {"time" => "1:00u", "letter" => "-", "adjust" => "0", "month" => 10, "years" => 1978..1978, "date" => "1"}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 9, "years" => 1979..1995}, {"time" => "1:00u", "lastdow" => 7, "letter" => "S", "adjust" => "1:00", "month" => 3, "years" => 1981..Inf}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 10, "years" => 1996..Inf}],
);
has @.zonedata = Array.new({"baseoffset" => "1:12:12", "rules" => "", "until" => -2871676800}, {"baseoffset" => "1:00:14", "rules" => "", "until" => -2208988800}, {"baseoffset" => "1:00", "rules" => "", "until" => -1692493200}, {"baseoffset" => "2:00", "rules" => "", "until" => -1680476400}, {"baseoffset" => "1:00", "rules" => "", "until" => 315532800}, {"baseoffset" => "1:00", "rules" => "EU", "until" => Inf});
