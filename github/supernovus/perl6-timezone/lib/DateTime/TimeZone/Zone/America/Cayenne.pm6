use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Cayenne does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-3:29:20"), :rules(""), :until(-1861920000)}, {:baseoffset("-4:00"), :rules(""), :until(-94694400)}, {:baseoffset("-3:00"), :rules(""), :until(Inf)}]<>;
