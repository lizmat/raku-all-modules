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
has $apiID = 'P6mod';
has $webAgent = HTTP::UserAgent.new();

subset SolarEclipses-YEAR of UInt where * eq any(1800..2050);
subset ValidEras of Str where * eq any( "AD", "CE", "BC", "BCE" );
subset ValidJulian of UInt where * < 5373484.5;
subset ObserChristan of UInt where * eq any( 1583..9999 );
subset ObserJewish of UInt where * eq any( 622..9999 );
subset ObserIslamic of UInt where * eq any( 360..9999 );
subset Body of Str where * eq any( "mercury", "venus", "venus-radar", "mars", "jupiter", "moon", "io", "europa", "ganymede", "callisto" );
subset Height of Int where * eq any (-90..10999);
subset Format of Str where * eq any( "json", "gojson" );
subset MoonPhase of UInt where * eq any(1..99);
subset View of Str where * eq any( "moon", "sun", "north", "south", "east", "west", "rise", "set" );

###########################################
## getJSON - method used to make request which will return JSON formatted data.
method getJSON( $template ) {
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
method getIMG( :$name, :$template ){
  my $file = $*CWD ~ "/"~ $name ~ ".png";
  my $url = $!baseURL ~ $template;
  say "Saving to $file ";
  $file.IO.spurt: :bin, get $url;
  say "{($file.path.s / 1024).fmt("%.1f")} KB received";
}
###########################################
## Cylindrical Projection.
method dayAndNight-Cylindrical( DateTime :$dateTimeObj ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{$dateTimeObj.hour}:{$dateTimeObj.minute}";
  my $template = "imagery/earth.png?date={ $date }&time={ $time }";
  self.getIMG( :name( "earth" ), :template( $template ) );
}
###########################################
## Spherical Projections.
method dayAndNight-Spherical( DateTime :$dateTimeObj, View :$view ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $template = "imagery/earth.png?date={ $date }&view={ $view }";
  self.getIMG( :name( "earth" ), :template( $template ) );
}

###########################################
## Apparent disk of a solar system object.
method apparentDisk( DateTime :$dateTimeObj, Body :$body ){
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{$dateTimeObj.hour}:{$dateTimeObj.minute}:{$dateTimeObj.second}";
  my $template = "imagery/{ $body }.png?date={ $date }&time={ $time }";
  self.getIMG( :name( $body ), :template($template)  );
}

###########################################
## Phases of the moon.
method moonPhase( DateTime :$dateTimeObj, MoonPhase :$numP  ){
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $template = "moon/phase?date={ $date }&nump={ $numP }";
  return self.getJSON( $template );
}

###########################################
## Complete sun and mood data for one day by lat and long.
multi method oneDayData-latlong( DateTime :$dateTimeObj, Str :$coords  ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $tz = $dateTimeObj.timezone / 3600;
  my $template = "rstt/oneday?date={ $date }&coords={ $coords }&tz={ $tz }";
  say self.getJSON( $template );
}

###########################################
## Complete sun and mood data for one day by location.
multi method oneDayData-location( DateTime :$dateTimeObj, Str :$loc ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $template = "rstt/oneday?date={ $date }&loc={ $loc }";
  return self.getJSON( $template );
}

###########################################
## Sideral Time
## TODO need to check if date is within 1 year past or 1 year in the future, range.
## TODO need to have some input checking for $intvUnit; can be 1 - 4 or a string.
multi method siderealTime( DateTime :$dateTimeObj, Str :$loc, UInt :$reps, UInt :$intvMag, :$intvUnit ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{$dateTimeObj.hour}:{$dateTimeObj.minute}:{$dateTimeObj.second}";
  my $template = "sidtime?date={ $date }&time={ $time }&loc={ $loc }&reps={ $reps }&intv_mag={ $intvMag }&intv_unit={ $intvUnit }";
  return self.getJSON( $template );
}

## TODO need to have some input checking for coords, and intvUnit.
multi method siderealTime( DateTime :$dateTimeObj, :$coords, UInt :$reps, UInt :$intvMag, :$intvUnit ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{$dateTimeObj.hour}:{$dateTimeObj.minute}:{$dateTimeObj.second}";
  my $template = "sidtime?date={ $date }&time={ $time }&coords={ $coords }&reps={ $reps }&intv_mag={ $intvMag }&intv_unit={ $intvUnit }";
  return self.getJSON( $template );
}

###########################################
## Solar eclipses caculator
multi method solarEclipses( SolarEclipses-YEAR $year ) {
  my $template = "eclipses/solar?year={ $year }";
  return self.getJSON( $template );
}

###########################################
## Solar eclipses caculator
## TODO Get Location type working...
multi method solarEclipses( DateTime :$dateTimeObj, :$loc, Height :$height, Format :$format  ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $template = "eclipses/solar?date={ $date }&loc={ $loc }&height={ $height }&format={ $format }";
  return self.getJSON( $template );
}

###########################################
## Solar eclipses caculator
# TODO get Coords type working...
multi method solarEclipses( DateTime :$dateTimeObj, :$coords, Height :$height, Format :$format  ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $template = "eclipses/solar?date={ $date }&coords={ $coords }&height={ $height }&format={ $format }";
  return self.getJSON( $template );
}


###########################################
## Selected Christian observances
method observancesChristan( ObserChristan :$year ) {
  #if $year != any( 1583...9999 ) { return "ERROR!! Invalid year. (only use 1583 to 9999)"; }
  my $template = "christian?year={ $year }";
  return self.getJSON( $template );
}

###########################################
## Selected Jewish observances
method observancesJewish( ObserJewish :$year ) {
  #if $year != any( 622...9999 ) { return "ERROR!! Invalid year. (only use 622 to 9999)"; }
  my $template = "jewish?year={ $year }";
  return self.getJSON( $template );
}

###########################################
## Selected Islamic observances
method observancesIslamic( ObserIslamic :$year ) {
  #if $year != any( 360...9999 ) { return "ERROR!! Invalid year. (only use 360 to 9999)"; }
  my $template = "islamic?year={ $year }";
  return self.getJSON( $template );
}

###########################################
## Julian date converter - From calender date to julian date
## TODO Need argument validation for date and era.
multi method julianDate( DateTime :$dateTimeObj, ValidEras :$era ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{ $dateTimeObj.hour }:{ $dateTimeObj.minute }:{ $dateTimeObj.second }";
  my $template = "jdconverter?date={ $date }&time={ $time }&era={ $era }";
  return self.getJSON( $template );
}

###########################################
## Julian date converter - From julian date to calender date.
multi method julianDate( ValidJulian :$julian ) {
  #if $julian < 0 or $julian > 5373484.5 { return "ERROR!! Julian date. (only use 0 to 5373484.5 )"; }
  my $template = "jdconverter?jd={ $julian }";
  return self.getJSON( $template );
}
