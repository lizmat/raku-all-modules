use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Aden does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("2:59:54"), :rules(""), :until(-631152000)}, {:baseoffset("3:00"), :rules(""), :until(Inf)}]<>;
