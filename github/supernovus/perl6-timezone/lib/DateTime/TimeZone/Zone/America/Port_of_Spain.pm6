use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Port_of_Spain does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-4:06:04"), :rules(""), :until(-1825113600)}, {:baseoffset("-4:00"), :rules(""), :until(Inf)}]<>;
