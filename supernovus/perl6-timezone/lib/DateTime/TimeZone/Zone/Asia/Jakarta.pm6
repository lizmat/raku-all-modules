use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Jakarta does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "7:07:12", "rules" => "", "until" => -3231273600}, {"baseoffset" => "7:07:12", "rules" => "", "until" => -1451693580}, {"baseoffset" => "7:20", "rules" => "", "until" => -1199232000}, {"baseoffset" => "7:30", "rules" => "", "until" => -876614400}, {"baseoffset" => "9:00", "rules" => "", "until" => -766022400}, {"baseoffset" => "7:30", "rules" => "", "until" => -694310400}, {"baseoffset" => "8:00", "rules" => "", "until" => -631152000}, {"baseoffset" => "7:30", "rules" => "", "until" => -189388800}, {"baseoffset" => "7:00", "rules" => "", "until" => Inf});
