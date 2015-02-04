use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Indian::Cocos does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "6:27:40", "rules" => "", "until" => -2208988800}, {"baseoffset" => "6:30", "rules" => "", "until" => Inf});
