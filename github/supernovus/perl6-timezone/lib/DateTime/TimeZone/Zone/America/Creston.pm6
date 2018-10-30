use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Creston does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-7:46:04"), :rules(""), :until(-2713910400)}, {:baseoffset("-7:00"), :rules(""), :until(-1680480000)}, {:baseoffset("-8:00"), :rules(""), :until(-1627862400)}, {:baseoffset("-7:00"), :rules(""), :until(Inf)}]<>;
