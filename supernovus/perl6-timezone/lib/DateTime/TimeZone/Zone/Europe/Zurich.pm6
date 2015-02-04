use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Europe::Zurich does DateTime::TimeZone::Zone;
has %.rules = ( 
 EU => [{"time" => "1:00u", "letter" => "S", "adjust" => "1:00", "month" => 4, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1977..1980}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 9, "years" => 1977..1977}, {"time" => "1:00u", "letter" => "-", "adjust" => "0", "month" => 10, "years" => 1978..1978, "date" => "1"}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 9, "years" => 1979..1995}, {"time" => "1:00u", "lastdow" => 7, "letter" => "S", "adjust" => "1:00", "month" => 3, "years" => 1981..Inf}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 10, "years" => 1996..Inf}],
 Swiss => [{"time" => "1:00", "letter" => "S", "adjust" => "1:00", "month" => 5, "dow" => {"mindate" => "1", "dow" => 1}, "years" => 1941..1942}, {"time" => "2:00", "letter" => "-", "adjust" => "0", "month" => 10, "dow" => {"mindate" => "1", "dow" => 1}, "years" => 1941..1942}],
);
has @.zonedata = Array.new({"baseoffset" => "0:34:08", "rules" => "", "until" => -3675196800}, {"baseoffset" => "0:29:46", "rules" => "", "until" => -2398291200}, {"baseoffset" => "1:00", "rules" => "Swiss", "until" => 347155200}, {"baseoffset" => "1:00", "rules" => "EU", "until" => Inf});
