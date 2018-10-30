use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Indian::Cocos does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("6:27:40"), :rules(""), :until(-2208988800)}, {:baseoffset("6:30"), :rules(""), :until(Inf)}]<>;
