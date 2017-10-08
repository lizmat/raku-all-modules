use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Thimphu does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("5:58:36"), :rules(""), :until(-706320000)}, {:baseoffset("5:30"), :rules(""), :until(536457600)}, {:baseoffset("6:00"), :rules(""), :until(Inf)}]<>;
