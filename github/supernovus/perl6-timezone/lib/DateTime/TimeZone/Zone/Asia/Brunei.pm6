use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Brunei does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("7:39:40"), :rules(""), :until(-1388534400)}, {:baseoffset("7:30"), :rules(""), :until(-1167609600)}, {:baseoffset("8:00"), :rules(""), :until(Inf)}]<>;
