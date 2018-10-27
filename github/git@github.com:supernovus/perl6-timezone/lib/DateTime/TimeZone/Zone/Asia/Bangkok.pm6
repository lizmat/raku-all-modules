use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Bangkok does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("6:42:04"), :rules(""), :until(-2840140800)}, {:baseoffset("6:42:04"), :rules(""), :until(-1577923200)}, {:baseoffset("7:00"), :rules(""), :until(Inf)}]<>;
