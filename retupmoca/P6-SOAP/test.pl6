use SOAP::Client;

my $s = SOAP::Client.new('converttemperature.xml');
say $s.call('ConvertTemp', Temperature => 32, FromUnit => 'degreeCelsius', ToUnit => 'degreeFahrenheit');