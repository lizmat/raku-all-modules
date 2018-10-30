#Weather

To get weather from openweathermap

##To get free api key

goto https://home.openweathermap.org/users/sign_up , you can use a disposable email if you do not want to give your real email. Once you logged in click on api keys link.

## Usage Example

```perl6
use Weather;
my $p = Weather.new(apikey => 'a7uie........o9'); # a7uie........o9 is an example key

$p.get-weather(' delhi '); # call get-weather() before calling other functions,
$p.get-weather(' delhi', ' in');   #can pass country code

$p.name;
$p.temperature;  # in celsius
$p.humidity;   # %
$p.pressure;   # at sea level in hPa
$p.cloudy;     # cloud percentage
$p.weather-description;   # description
$p.weather-main;  
$p.latitude;  
$p.longitude;
$p.country;
$p.wind-speed;   # in meter/sec
$p.wind-direction;  # in degree,  north-based azimuths
$p.sunrise;   # in local time
$p.sunset;    # in local time
$p.rain;   # volume in last 3 hrs

my $temp = $p.temparature;
say $temp;
say $p.sunrise;
