#########################################
## Michael D. Hensley
## May 13, 2017
## Perl 6 module use to easily interface with the U.S. Naval Observatory's Astronomical Applications API.
## Currently based on the 2.0.1 version of the API.
use v6.c;

unit class API::USNavalObservatory;
use HTTP::UserAgent;
use URI::Encode;
use WWW;
has $!baseURL = 'api.usno.navy.mil/';
has @!validEras = "AD", "CE", "BC", "BCE";
has $apiID = 'P6mod'; # Default ID, feel free to use an ID of your own and  override.
has $outputDir = $*CWD; # Current working Dir is the default output dir for images
has $webAgent = HTTP::UserAgent.new();

subset SolarEclipses-YEAR of UInt where * eq any( 1800..2050 );
subset ValidEras of Str where * eq any( "AD", "CE", "BC", "BCE" );
subset ValidJulian of UInt where * < 5373484.5;
subset ObserChristan of UInt where * eq any( 1583..9999 );
subset ObserJewish of UInt where * eq any( 622..9999 );
subset ObserIslamic of UInt where * eq any( 360..9999 );
subset Body of Str where * eq any( "mercury", "venus", "venus-radar", "mars", "jupiter", "moon", "io", "europa", "ganymede", "callisto" );
subset Height of Int where * eq any ( -90..10999 );
subset Format of Str where * eq any( "json", "gojson" );
subset MoonPhase of UInt where * eq any( 1..99 );
subset View of Str where * eq any( "moon", "sun", "north", "south", "east", "west", "rise", "set" );

my regex coords { \-? \d+[\.\d+]? [N|S]? \,\s \-? \d+[\.\d+]? [E|W]? };
my regex loc { ['St.' || <alpha> ]? \s? <alpha>+ \, \s \w**2 };

###########################################
## getJSON - method used to make request which will return JSON formatted data.
method !getJSON( $template ) {
  my $encoded_uri = uri_encode( $!baseURL ~ $template ~ "&id={ $apiID }" );
  my $response = $webAgent.get( $encoded_uri );
  if $response.is-success {
    return $response.content;
    }
    else {
      return $response.status-line;
  }
}
###########################################
## getIMG - method used to make request which will return .png files.
## TODO: change the default location of the base direcotry
method !getIMG( :$name, :$template ){
  my $file = $outputDir ~ "/"~ $name ~ ".png";
  my $url = $!baseURL ~ $template;
  say "Saving to $file ";
  $file.IO.spurt: :bin, get $url;
  say "{($file.path.s / 1024).fmt("%.1f")} KB received";
}

###########################################
## Cylindrical Projection.

# querry with a date and time
mulit method dayAndNight-Cylindrical( DateTime :$dateTimeObj ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{$dateTimeObj.hour}:{$dateTimeObj.minute}";
  my $template = "imagery/earth.png?date={ $date }&time={ $time }";
  self.getIMG( :name( "earth" ), :template( $template ) );
}

# querry with date only
mulit method dayAndNight-Cylindrical( Date :$dateObj ) {
  my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
  my $template = "imagery/earth.png?date={ $date }";
  self.getIMG( :name( "earth" ), :template( $template ) );
}


###########################################
## Spherical Projections.
method dayAndNight-Spherical( Date :$dateObj, View :$view ) {
  my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
  my $template = "imagery/earth.png?date={ $date }&view={ $view }";
  self!getIMG( :name( "earth" ), :template( $template ) );
}

###########################################
## Apparent disk of a solar system object.
method apparentDisk( DateTime :$dateTimeObj, Body :$body ){
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{$dateTimeObj.hour}:{$dateTimeObj.minute}:{$dateTimeObj.second}";
  my $template = "imagery/{ $body }.png?date={ $date }&time={ $time }";
  self!getIMG( :name( $body ), :template($template)  );
}

###########################################
## Phases of the moon.
multi method moonPhase( Date :$dateObj, MoonPhase :$numP  ){
  my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
  my $template = "moon/phase?date={ $date }&nump={ $numP }";
  return self!getJSON( $template );
}

multi method moonPhase( UInt :$year where * eq any( 1700 ..2100 )){
  # 1700 and 2100 are the only valid years which can be used.
  my $template = "moon/phase?year={ $year }";
  return self!getJSON( $template );
}

###########################################
## Complete sun and mood data for one day by lat and long.
multi method oneDayData-latlong( DateTime :$dateTimeObj, Str :$coords  ) {
  try {
    if $coords !~~ / <coords> / { die; }
      CATCH { say 'Invalid coords passed!'; }
  }
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $tz = $dateTimeObj.timezone / 3600;
  my $template = "rstt/oneday?date={ $date }&coords={ $coords }&tz={ $tz }";
  say self!getJSON( $template );
}

###########################################
## Complete sun and mood data for one day by location.
multi method oneDayData-location( Date :$dateObj, Str :$loc ) {
  try {
    if $loc !~~ / <loc> / { die; }
    CATCH { say 'Invalid location passed!'; }
  }
  my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
  my $template = "rstt/oneday?date={ $date }&loc={ $loc }";
  return self!getJSON( $template );
}

###########################################
## Sideral Time
## TODO need to check if date is within 1 year past or 1 year in the future, range. DONE!!
## TODO need to have some input checking for $intvUnit; can be 1 - 4 or a string. DONE!!
multi method siderealTime( DateTime :$dateTimeObj, Str :$loc, UInt :$reps, UInt :$intvMag, :$intvUnit ) {

try {
    if $loc !~~ / <loc> / { die; } ## Check if the location value matches a valid pattern.
    if $dateTimeObj < $today.later(year => -1) or $dateTimeObj > $today.later(year => 1)  { die; }
    if $intvUnit !~~ /[1..4] | ['day' | 'hour' | 'minuet' | 'second'] /  { die; }
    CATCH { say 'Invalid data passed!'; }
  }

  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{$dateTimeObj.hour}:{$dateTimeObj.minute}:{$dateTimeObj.second}";

  my $template = "sidtime?date={ $date }&time={ $time }&loc={ $loc }&reps={ $reps }&intv_mag={ $intvMag }&intv_unit={ $intvUnit }";
  return self!getJSON( $template );
}

## TODO need to have some input checking for coords, and intvUnit.
multi method siderealTime( DateTime :$dateTimeObj, :$coords, UInt :$reps, UInt :$intvMag, :$intvUnit ) {
  try {
      if $coords !~~ / <coords> / { die; }
      if $dateTimeObj < $today.later(year => -1) or $dateTimeObj > $today.later(year => 1)  { die; }
      if $intvUnit !~~ /[1..4] | ['day' | 'hour' | 'minuet' | 'second'] /  { die; }
      CATCH { say 'Invalid data passed!'; }
  }

  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{$dateTimeObj.hour}:{$dateTimeObj.minute}:{$dateTimeObj.second}";
  my $template = "sidtime?date={ $date }&time={ $time }&coords={ $coords }&reps={ $reps }&intv_mag={ $intvMag }&intv_unit={ $intvUnit }";
  return self!getJSON( $template );
}

###########################################
## Solar eclipses caculator
multi method solarEclipses( SolarEclipses-YEAR :$year ) {
  my $template = "eclipses/solar?year={ $year }";
  return self!getJSON( $template );
}

###########################################
## Solar eclipses caculator
## TODO Get Location type working...
multi method solarEclipses( Date :$dateObj, :$loc, Height :$height, Format :$format  ) {
  my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
  my $template = "eclipses/solar?date={ $date }&loc={ $loc }&height={ $height }&format={ $format }";
  return self!getJSON( $template );
}

###########################################
## Solar eclipses caculator
# TODO get Coords type working...
multi method solarEclipses( Date :$dateObj, :$coords, Height :$height, Format :$format  ) {
  try {
    if $coords !~~ / <coords> / { die };
      CATCH { say "Invalid coords passed!"; }
  }
  my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
  my $template = "eclipses/solar?date={ $date }&coords={ $coords }&height={ $height }&format={ $format }";
  return self!getJSON( $template );
}

###########################################
## Selected Christian observances
method observancesChristan( ObserChristan :$year ) {
  #if $year != any( 1583...9999 ) { return "ERROR!! Invalid year. (only use 1583 to 9999)"; }
  my $template = "christian?year={ $year }";
  return self!getJSON( $template );
}

###########################################
## Selected Jewish observances
method observancesJewish( ObserJewish :$year ) {
  #if $year != any( 622...9999 ) { return "ERROR!! Invalid year. (only use 622 to 9999)"; }
  my $template = "jewish?year={ $year }";
  return self!getJSON( $template );
}

###########################################
## Selected Islamic observances
method observancesIslamic( ObserIslamic :$year ) {
  #if $year != any( 360...9999 ) { return "ERROR!! Invalid year. (only use 360 to 9999)"; }
  my $template = "islamic?year={ $year }";
  return self!getJSON( $template );
}

###########################################
## Julian date converter - From calender date to julian date
## TODO Need argument validation for date and era.
multi method julianDate( DateTime :$dateTimeObj, ValidEras :$era ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{ $dateTimeObj.hour }:{ $dateTimeObj.minute }:{ $dateTimeObj.second }";
  my $template = "jdconverter?date={ $date }&time={ $time }&era={ $era }";
  return self!getJSON( $template );
}

###########################################
## Julian date converter - From julian date to calender date.
multi method julianDate( ValidJulian :$julian ) {
  #if $julian < 0 or $julian > 5373484.5 { return "ERROR!! Julian date. (only use 0 to 5373484.5 )"; }
  my $template = "jdconverter?jd={ $julian }";
  return self!getJSON( $template );
}
