use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Muscat does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("3:54:24"), :rules(""), :until(-1577923200)}, {:baseoffset("4:00"), :rules(""), :until(Inf)}]<>;
