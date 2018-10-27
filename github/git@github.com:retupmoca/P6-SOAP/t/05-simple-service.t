use v6;
use Test;

plan 6;

use SOAP::Client;

my $temp = SOAP::Client.new('http://www.webservicex.net/ConvertTemperature.asmx?WSDL');
ok $temp, "Got a SOAP::Client object for ConvertTemperature";

my $result = $temp.call('ConvertTemp', Temperature => 32, FromUnit => 'degreeCelsius', ToUnit => 'degreeFahrenheit');
ok $result, "Got a result for a temperature conversion";
is $result<ConvertTempResult>, 89.6, "Got correct result";

my $stats = SOAP::Client.new('http://www.webservicex.net/Statistics.asmx?WSDL');
ok $stats, "Got a SOAP::Client object for Statistics";

$result = $stats.call('GetStatistics', X => {double => [1, 2, 3]});
ok $result, "Got a result for Statistics";
is $result<Sums>, 6, "Got correct result";
