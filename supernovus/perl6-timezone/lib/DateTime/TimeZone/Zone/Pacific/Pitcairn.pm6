use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Pitcairn does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-8:40:20"), :rules(""), :until(-2177452800)}, {:baseoffset("-8:30"), :rules(""), :until(893635200)}, {:baseoffset("-8:00"), :rules(""), :until(Inf)}]<>;
