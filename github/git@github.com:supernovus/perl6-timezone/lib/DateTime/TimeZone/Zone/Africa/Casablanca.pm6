use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Casablanca does DateTime::TimeZone::Zone;
has %.rules = ( 
 Morocco => [{:adjust("1:00"), :date("12"), :letter("S"), :month(9), :time("0:00"), :years(1939..1939)}, {:adjust("0"), :date("19"), :letter("-"), :month(11), :time("0:00"), :years(1939..1939)}, {:adjust("1:00"), :date("25"), :letter("S"), :month(2), :time("0:00"), :years(1940..1940)}, {:adjust("0"), :date("18"), :letter("-"), :month(11), :time("0:00"), :years(1945..1945)}, {:adjust("1:00"), :date("11"), :letter("S"), :month(6), :time("0:00"), :years(1950..1950)}, {:adjust("0"), :date("29"), :letter("-"), :month(10), :time("0:00"), :years(1950..1950)}, {:adjust("1:00"), :date("3"), :letter("S"), :month(6), :time("12:00"), :years(1967..1967)}, {:adjust("0"), :date("1"), :letter("-"), :month(10), :time("0:00"), :years(1967..1967)}, {:adjust("1:00"), :date("24"), :letter("S"), :month(6), :time("0:00"), :years(1974..1974)}, {:adjust("0"), :date("1"), :letter("-"), :month(9), :time("0:00"), :years(1974..1974)}, {:adjust("1:00"), :date("1"), :letter("S"), :month(5), :time("0:00"), :years(1976..1977)}, {:adjust("0"), :date("1"), :letter("-"), :month(8), :time("0:00"), :years(1976..1976)}, {:adjust("0"), :date("28"), :letter("-"), :month(9), :time("0:00"), :years(1977..1977)}, {:adjust("1:00"), :date("1"), :letter("S"), :month(6), :time("0:00"), :years(1978..1978)}, {:adjust("0"), :date("4"), :letter("-"), :month(8), :time("0:00"), :years(1978..1978)}, {:adjust("1:00"), :date("1"), :letter("S"), :month(6), :time("0:00"), :years(2008..2008)}, {:adjust("0"), :date("1"), :letter("-"), :month(9), :time("0:00"), :years(2008..2008)}, {:adjust("1:00"), :date("1"), :letter("S"), :month(6), :time("0:00"), :years(2009..2009)}, {:adjust("0"), :date("21"), :letter("-"), :month(8), :time("0:00"), :years(2009..2009)}, {:adjust("1:00"), :date("2"), :letter("S"), :month(5), :time("0:00"), :years(2010..2010)}, {:adjust("0"), :date("8"), :letter("-"), :month(8), :time("0:00"), :years(2010..2010)}, {:adjust("1:00"), :date("3"), :letter("S"), :month(4), :time("0:00"), :years(2011..2011)}, {:adjust("0"), :date("31"), :letter("-"), :month(7), :time("0"), :years(2011..2011)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(4), :time("2:00"), :years(2012..2013)}, {:adjust("0"), :date("30"), :letter("-"), :month(9), :time("3:00"), :years(2012..2012)}, {:adjust("0"), :date("20"), :letter("-"), :month(7), :time("3:00"), :years(2012..2012)}, {:adjust("1:00"), :date("20"), :letter("S"), :month(8), :time("2:00"), :years(2012..2012)}, {:adjust("0"), :date("7"), :letter("-"), :month(7), :time("3:00"), :years(2013..2013)}, {:adjust("1:00"), :date("10"), :letter("S"), :month(8), :time("2:00"), :years(2013..2013)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(10), :time("3:00"), :years(2013..2035)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(3), :time("2:00"), :years(2014..2022)}, {:adjust("0"), :date("29"), :letter("-"), :month(6), :time("3:00"), :years(2014..2014)}, {:adjust("1:00"), :date("29"), :letter("S"), :month(7), :time("2:00"), :years(2014..2014)}, {:adjust("0"), :date("18"), :letter("-"), :month(6), :time("3:00"), :years(2015..2015)}, {:adjust("1:00"), :date("18"), :letter("S"), :month(7), :time("2:00"), :years(2015..2015)}, {:adjust("0"), :date("7"), :letter("-"), :month(6), :time("3:00"), :years(2016..2016)}, {:adjust("1:00"), :date("7"), :letter("S"), :month(7), :time("2:00"), :years(2016..2016)}, {:adjust("0"), :date("27"), :letter("-"), :month(5), :time("3:00"), :years(2017..2017)}, {:adjust("1:00"), :date("26"), :letter("S"), :month(6), :time("2:00"), :years(2017..2017)}, {:adjust("0"), :date("16"), :letter("-"), :month(5), :time("3:00"), :years(2018..2018)}, {:adjust("1:00"), :date("15"), :letter("S"), :month(6), :time("2:00"), :years(2018..2018)}, {:adjust("0"), :date("6"), :letter("-"), :month(5), :time("3:00"), :years(2019..2019)}, {:adjust("1:00"), :date("5"), :letter("S"), :month(6), :time("2:00"), :years(2019..2019)}, {:adjust("0"), :date("24"), :letter("-"), :month(4), :time("3:00"), :years(2020..2020)}, {:adjust("1:00"), :date("24"), :letter("S"), :month(5), :time("2:00"), :years(2020..2020)}, {:adjust("0"), :date("13"), :letter("-"), :month(4), :time("3:00"), :years(2021..2021)}, {:adjust("1:00"), :date("13"), :letter("S"), :month(5), :time("2:00"), :years(2021..2021)}, {:adjust("0"), :date("3"), :letter("-"), :month(4), :time("3:00"), :years(2022..2022)}, {:adjust("1:00"), :date("3"), :letter("S"), :month(5), :time("2:00"), :years(2022..2022)}, {:adjust("1:00"), :date("22"), :letter("S"), :month(4), :time("2:00"), :years(2023..2023)}, {:adjust("1:00"), :date("10"), :letter("S"), :month(4), :time("2:00"), :years(2024..2024)}, {:adjust("1:00"), :date("31"), :letter("S"), :month(3), :time("2:00"), :years(2025..2025)}, {:adjust("1:00"), :lastdow(7), :letter("S"), :month(3), :time("2:00"), :years(2026..Inf)}, {:adjust("0"), :date("21"), :letter("-"), :month(10), :time("3:00"), :years(2036..2036)}, {:adjust("0"), :date("11"), :letter("-"), :month(10), :time("3:00"), :years(2037..2037)}, {:adjust("0"), :date("30"), :letter("-"), :month(9), :time("3:00"), :years(2038..2038)}, {:adjust("1:00"), :date("30"), :letter("S"), :month(10), :time("2:00"), :years(2038..2038)}, {:adjust("0"), :lastdow(7), :letter("-"), :month(10), :time("3:00"), :years(2038..Inf)}],
);
has @.zonedata = [{:baseoffset("-0:30:20"), :rules(""), :until(-1773014400)}, {:baseoffset("0:00"), :rules("Morocco"), :until(448243200)}, {:baseoffset("1:00"), :rules(""), :until(504921600)}, {:baseoffset("0:00"), :rules("Morocco"), :until(Inf)}]<>;