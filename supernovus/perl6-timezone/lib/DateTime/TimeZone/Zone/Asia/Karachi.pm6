use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Karachi does DateTime::TimeZone::Zone;
has %.rules = ( 
 Pakistan => [{"time" => "0:01", "letter" => "S", "adjust" => "1:00", "month" => 4, "dow" => {"mindate" => "2", "dow" => 7}, "years" => 2002..2002}, {"time" => "0:01", "letter" => "-", "adjust" => "0", "month" => 10, "dow" => {"mindate" => "2", "dow" => 7}, "years" => 2002..2002}, {"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 6, "years" => 2008..2008, "date" => "1"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 11, "years" => 2008..2008, "date" => "1"}, {"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 4, "years" => 2009..2009, "date" => "15"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 11, "years" => 2009..2009, "date" => "1"}],
);
has @.zonedata = Array.new({"baseoffset" => "4:28:12", "rules" => "", "until" => -1988150400}, {"baseoffset" => "5:30", "rules" => "", "until" => -883612800}, {"baseoffset" => "6:30", "rules" => "", "until" => -764121600}, {"baseoffset" => "5:30", "rules" => "", "until" => -576115200}, {"baseoffset" => "5:00", "rules" => "", "until" => 38793600}, {"baseoffset" => "5:00", "rules" => "Pakistan", "until" => Inf});
