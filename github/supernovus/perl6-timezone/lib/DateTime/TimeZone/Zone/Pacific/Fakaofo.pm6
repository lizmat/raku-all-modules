use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Fakaofo does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-11:24:56"), :rules(""), :until(-2177452800)}, {:baseoffset("-11:00"), :rules(""), :until(1325203200)}, {:baseoffset("13:00"), :rules(""), :until(Inf)}]<>;
