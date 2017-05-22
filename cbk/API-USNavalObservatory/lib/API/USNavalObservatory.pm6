#########################################
## Michael D. Hensley
## May 13, 2017
## Perl 6 module use to easily interface with the U.S. Naval Observatory's Astronomical Applications API.
## Currently based on the 2.0.1 version of the API.
use v6.c;

unit class API::USNavalObservatory;
use HTTP::UserAgent;
has $!baseURL = 'api.usno.navy.mil/';
has @!validEras = "AD", "CE", "BC", "BCE";
has $apiID = 'P6mod';
has $webAgent = HTTP::UserAgent.new(useragent => "Chrome/41.0");

subset solarEclipses-YEAR of UInt where * eq any(1800..2050);

###########################################
## getJSON - method used to make request which will reutrn JSON formatted data.
method getJSON( $template ) {
  my $response = $webAgent.get( $!baseURL ~ $template ~ "&id={$apiID}" );
  if $response.is-success {
    return $response.content;
    }
    else {
      return $response.status-line;
  }
}

###########################################
## Cylindrical Projection.

###########################################
## Spherical Projections.

###########################################
## Apparent disk of a solar system object.

###########################################
## Phases of the moon.

###########################################
## Complete sun and mood data for one day

###########################################
## Sideral time.


###########################################
## Solar eclipses caculator
multi method solarEclipses( solarEclipses-YEAR $year ) {
  my $template = "eclipses/solar?year={ $year }";
  return self.getJSON( $template );
}

###########################################
## Selected Christian observances
method observancesChristan( UInt $year ) {
  if $year != any( 1583...9999 ) { return "ERROR!! Invalid year. (only use 1583 to 9999)"; }
  my $template = "christian?year={ $year }";
  return self.getJSON( $template );
}

###########################################
## Selected Jewish observances
method observancesJewish( UInt $year ) {
  if $year != any( 622...9999 ) { return "ERROR!! Invalid year. (only use 622 to 9999)"; }
  my $template = "jewish?year={ $year }";
  return self.getJSON( $template );
}

###########################################
## Selected Islamic observances
method observancesIslamic( UInt $year ) {
  if $year != any( 360...9999 ) { return "ERROR!! Invalid year. (only use 360 to 9999)"; }
  my $template = "islamic?year={ $year }";
  return self.getJSON( $template );
}

###########################################
## Julian date converter - From calender date to julian date
## TODO Need argument validation for date and era.
multi method julianDate( $dateTimeObj, $era ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{$dateTimeObj.hour}:{$dateTimeObj.minute}:{$dateTimeObj.second}";
  my $template = "jdconverter?date={ $date }&time={ $time }&era={ $era }";
  return self.getJSON( $template );
}

###########################################
## Julian date converter - From julian date to calender date.
multi method julianDate( $julian ) {
  if $julian < 0 or $julian > 5373484.5 { return "ERROR!! Julian date. (only use 0 to 5373484.5 )"; }
  my $template = "jdconverter?jd={ $julian }";
  return self.getJSON( $template );
}
