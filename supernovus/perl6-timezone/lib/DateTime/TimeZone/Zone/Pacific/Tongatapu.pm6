use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Tongatapu does DateTime::TimeZone::Zone;
has %.rules = ( 
 Tonga => [{"time" => "2:00s", "letter" => "S", "adjust" => "1:00", "month" => 10, "years" => 1999..1999, "date" => "7"}, {"time" => "2:00s", "letter" => "-", "adjust" => "0", "month" => 3, "years" => 2000..2000, "date" => "19"}, {"time" => "2:00", "letter" => "S", "adjust" => "1:00", "month" => 11, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 2000..2001}, {"time" => "2:00", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 1, "years" => 2001..2002}],
);
has @.zonedata = Array.new({"baseoffset" => "12:19:20", "rules" => "", "until" => -2177452800}, {"baseoffset" => "12:20", "rules" => "", "until" => -915148800}, {"baseoffset" => "13:00", "rules" => "", "until" => 915148800}, {"baseoffset" => "13:00", "rules" => "Tonga", "until" => Inf});
