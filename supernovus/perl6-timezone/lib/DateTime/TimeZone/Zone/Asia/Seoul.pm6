use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Seoul does DateTime::TimeZone::Zone;
has %.rules = ( 
 ROK => [{"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "years" => 1960..1960, "date" => "15"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 9, "years" => 1960..1960, "date" => "13"}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "dow" => {"mindate" => "8", "dow" => 7}, "years" => 1987..1988}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 10, "dow" => {"mindate" => "8", "dow" => 7}, "years" => 1987..1988}],
);
has @.zonedata = Array.new({"baseoffset" => "8:27:52", "rules" => "", "until" => -2524521600}, {"baseoffset" => "8:30", "rules" => "", "until" => -2082844800}, {"baseoffset" => "9:00", "rules" => "", "until" => -1325462400}, {"baseoffset" => "8:30", "rules" => "", "until" => -1199232000}, {"baseoffset" => "9:00", "rules" => "", "until" => -498096000}, {"baseoffset" => "8:00", "rules" => "ROK", "until" => -264902400}, {"baseoffset" => "8:30", "rules" => "", "until" => -63158400}, {"baseoffset" => "9:00", "rules" => "ROK", "until" => Inf});
