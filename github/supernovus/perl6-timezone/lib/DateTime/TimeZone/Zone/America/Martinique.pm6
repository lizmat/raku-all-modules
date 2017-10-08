use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Martinique does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-4:04:20"), :rules(""), :until(-2524521600)}, {:baseoffset("-4:04:20"), :rules(""), :until(-1861920000)}, {:baseoffset("-4:00"), :rules(""), :until(323827200)}, {:baseoffset("-3:00"), :rules(""), :until(338947200)}, {:baseoffset("-4:00"), :rules(""), :until(Inf)}]<>;
