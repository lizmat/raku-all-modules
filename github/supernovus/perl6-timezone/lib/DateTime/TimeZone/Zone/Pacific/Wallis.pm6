use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Wallis does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("12:15:20"), :rules(""), :until(-2177452800)}, {:baseoffset("12:00"), :rules(""), :until(Inf)}]<>;
