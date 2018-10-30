use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Kuwait does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("3:11:56"), :rules(""), :until(-631152000)}, {:baseoffset("3:00"), :rules(""), :until(Inf)}]<>;
