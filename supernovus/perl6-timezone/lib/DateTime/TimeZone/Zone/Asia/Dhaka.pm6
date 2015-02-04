use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Dhaka does DateTime::TimeZone::Zone;
has %.rules = ( 
 Dhaka => [{"time" => "23:00", "letter" => "S", "adjust" => "1:00", "month" => 6, "years" => 2009..2009, "date" => "19"}, {"time" => "23:59", "letter" => "-", "adjust" => "0", "month" => 12, "years" => 2009..2009, "date" => "31"}],
);
has @.zonedata = Array.new({"baseoffset" => "6:01:40", "rules" => "", "until" => -2524521600}, {"baseoffset" => "5:53:20", "rules" => "", "until" => -915148800}, {"baseoffset" => "6:30", "rules" => "", "until" => -872035200}, {"baseoffset" => "5:30", "rules" => "", "until" => -883612800}, {"baseoffset" => "6:30", "rules" => "", "until" => -576115200}, {"baseoffset" => "6:00", "rules" => "", "until" => 38793600}, {"baseoffset" => "6:00", "rules" => "", "until" => 1230768000}, {"baseoffset" => "6:00", "rules" => "Dhaka", "until" => Inf});
