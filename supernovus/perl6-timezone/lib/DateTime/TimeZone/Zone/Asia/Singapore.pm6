use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Singapore does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "6:55:25", "rules" => "", "until" => -2177452800}, {"baseoffset" => "6:55:25", "rules" => "", "until" => -2038176000}, {"baseoffset" => "7:00", "rules" => "", "until" => -1167609600}, {"baseoffset" => "7:00", "rules" => "", "until" => -1073001600}, {"baseoffset" => "7:20", "rules" => "", "until" => -894153600}, {"baseoffset" => "7:30", "rules" => "", "until" => -879638400}, {"baseoffset" => "9:00", "rules" => "", "until" => -766972800}, {"baseoffset" => "7:30", "rules" => "", "until" => -138758400}, {"baseoffset" => "7:30", "rules" => "", "until" => 378691200}, {"baseoffset" => "8:00", "rules" => "", "until" => Inf});
