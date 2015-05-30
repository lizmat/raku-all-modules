use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Enderbury does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-11:24:20"), :rules(""), :until(-2177452800)}, {:baseoffset("-12:00"), :rules(""), :until(283996800)}, {:baseoffset("-11:00"), :rules(""), :until(788918400)}, {:baseoffset("13:00"), :rules(""), :until(Inf)}]<>;
