#########################################
## Michael D. Hensley
## May 13, 2017
## Perl 6 module use to easily interface with the U.S. Naval Observatory's Astronomical Applications API.
## Currently based on the 2.0.1 version of the API.
use v6.c;
unit class API::USNavalObservatory;
#use JSON::Fast;
use HTTP::UserAgent;
has $webAgent = HTTP::UserAgent.new(useragent => "Chrome/41.0");
has $baseUrl = 'api.usno.navy.mil';
has @validEras = "AD", "CE", "BC", "BCE";
has $apiID = 'MDHTest';


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
## Solar eclipse calculator

###########################################
## Selected Christian observances
method observancesChristan( UInt $year ) {
  if $year != any( 1583...9999 ) { return "ERROR!! Invalid year. (only use 1583 to 9999)"; }
  my $template = "christian?year={ $year }";
  my $response = $webAgent.get( self.baseURL ~ $template );
  if $response.is-success {
    return $response.content;
    }
    else {
      return $response.status-line;
  }
}
###########################################
## Selected Jewish observances
method observancesJewish( UInt $year ) {
  if $year != any( 622...9999 ) { return "ERROR!! Invalid year. (only use 622 to 9999)"; }
  my $template = "jewish?year={ $year }";
  my $response = $webAgent.get( self.baseURL ~ $template );
  if $response.is-success {
    return $response.content;
    }
    else {
      return $response.status-line;
  }
}
###########################################
## Selected Islamic observances
method observancesIslamic( UInt $year ) {
  if $year != any( 360...9999 ) { return "ERROR!! Invalid year. (only use 360 to 9999)"; }
  my $template = "islamic?year={ $year }";
  my $response = $webAgent.get( self.baseURL ~ $template );
  if $response.is-success {
    return $response.content;
    }
    else {
      return $response.status-line;
  }
}
###########################################
## Julian date converter
multi julianDate( $dateTimeObj, $era ) {
  my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
  my $time = "{$dateTimeObj.hour}:{$dateTimeObj.minute}:{$dateTimeObj.second}";
  my $template = "jdconverter?date={ $date }&time={ $time }&era={ $era }";
  my $response = $webAgent.get( self.baseURL ~ $template );
  if $response.is-success {
    return $response.content;
    }
    else {
      return $response.status-line;
  }
}

multi julianDate( $julian ) {
  if $julian < 0 or $julian > 5373484.5 { return "ERROR!! Julian date. (only use 0 to 5373484.5 )"; }
  my $template = "jdconverter?jd={ $julian }";
  my $response = $webAgent.get( self.baseURL ~ $template );
  if $response.is-success {
    return $response.content;
    }
    else {
      return $response.status-line;
  }
}
