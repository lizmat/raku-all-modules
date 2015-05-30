use NativeCall;

unit class GeoIP::City is repr('CPointer');

class GeoIPRecord is repr('CStruct') {
    has Str $.country_code;
    has Str $.country_code3;
    has Str $.country_name;
    has Str $.region;
    has Str $.city;
    has Str $.postal_code;
    has num32 $.latitude;
    has num32 $.longitude;
    has int32 $.dma_code;
    has int32 $.area_code;
    has int32 $.charset;
    has Str $.continent_code;
    has int8 $.country_conf;
    has int8 $.region_conf;
    has int8 $.city_conf;
    has int8 $.postal_conf;
    has int32 $.accuracy_radius;
};

# point NativeCall to correct library
# (may become obsolete in the future)
sub LIB  {
    given $*VM.config{'load_ext'} {
        when '.so'      { return 'libGeoIP.so.1' }   # Linux
        when '.bundle'  { return 'libGeoIP.dylib' }  # Mac OS
        default         { return 'libGeoIP' }
    }
}

# initialize database
sub GeoIP_open ( Str, Int ) returns GeoIP::City is native( LIB ) { * }
sub GeoIP_open_type ( Int, Int ) returns GeoIP::City is native( LIB ) { * }
sub GeoIP_set_charset ( GeoIP::City, Int ) returns Int is native( LIB ) { * }

sub GeoIP_database_info ( GeoIP::City ) returns Str is native( LIB ) { * }

sub GeoIP_record_by_name (GeoIP::City, Str) returns GeoIPRecord is native( LIB ) { * }
sub GeoIP_record_by_addr (GeoIP::City, Str) returns GeoIPRecord is native( LIB ) { * }
sub GeoIP_region_name_by_code ( Str, Str ) returns Str is native( LIB ) { * }
sub GeoIP_time_zone_by_country_and_region ( Str, Str ) returns Str is native( LIB ) { * }

multi method new ( ) {

    # open GEOIP_CITY_EDITION_REV1 by default
    # because this free version is distributed
    # in most package repositories
    my $self = GeoIP_open_type( 2, 0 );

    GeoIP_set_charset( $self, 1 );

    return $self;
}

multi method new ( Str $file! where $_.IO ~~ :f & :r ) {

    # open any GEOIP_CITY_EDITION_* file provided
    my $self = GeoIP_open( $file, 0 );

    GeoIP_set_charset( $self, 1 );

    return $self;
}

method info {
    return GeoIP_database_info( self );
}

multi method locate ( Str $ip! where /^\d+\.\d+\.\d+\.\d+$/ ) {
    return self!derive( GeoIP_record_by_addr( self, $ip ) );
}

multi method locate ( Str $host! ) {
    return self!derive( GeoIP_record_by_name( self, $host ) );
}

method !derive ( GeoIPRecord $record! ) {
    return unless defined $record;

    my %result;

    %result{'area_code'} = $record.area_code
        if defined $record.area_code;

    %result{'city'} = $record.city
        if defined $record.city;

    %result{'continent_code'} = $record.continent_code
        if defined $record.continent_code;

    %result{'country'} = $record.country_name
        if defined $record.country_name;

    %result{'country_code'} = $record.country_code
        if defined $record.country_code;

    %result{'dma_code'} = $record.dma_code
        if defined $record.dma_code;

    %result{'latitude'} = $record.latitude.fmt( '%f' )
        if defined $record.latitude;

    %result{'longitude'} = $record.longitude.fmt( '%f' )
        if defined $record.longitude;

    %result{'postal_code'} = $record.postal_code
        if defined $record.postal_code;

    %result{'region'} = GeoIP_region_name_by_code(
        $record.country_code, $record.region
    ) if defined $record.country_code and defined $record.region;

    %result{'region_code'} = $record.region
        if defined $record.region;

    %result{'time_zone'} = GeoIP_time_zone_by_country_and_region(
        $record.country_code, $record.region
    ) if defined $record.country_code and defined $record.region;

    return %result;
}
