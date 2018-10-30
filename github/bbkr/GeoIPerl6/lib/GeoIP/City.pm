unit class GeoIP::City:auth<github:bbkr>:ver<1.0.2>;

use GeoIP:ver<1.0.2>;
use NativeCall;

has GeoIP %!db;

class X::DatabaseMissing is Exception is export { };

submethod BUILD ( Str :$directory where { .defined.not or .IO ~~ :d } ) {
    
    # change default directory
    GeoIP_setup_custom_directory( CArray[ uint8 ].new( .encode.list, 0 ) ) with $directory;
    
    # initialize GeoIPCity.dat and GeoIPCityv6.dat databases
    for GEOIP_CITY_EDITION_REV1, GEOIP_CITY_EDITION_REV1_V6 {
        
        # check if database is available
        next unless GeoIP_db_avail( +$_ );
        
        # open database
        %!db{ $_ } = GeoIP_open_type( +$_, 0 );
        
        # set UTF-8 encoding
        GeoIP_set_charset( %!db{ $_ }, 1 );
    }
    
    # clean up directory paths
    GeoIP_cleanup( );
}

method info {
    
    return map { .key => GeoIP_database_info( .value ) }, %!db;
}

method !locate ( Record $record! ) {
    
    return unless defined $record;

    my %result;

    %result{ 'area_code' } = $_ with $record.area_code;

    %result{ 'city' } = $_ with $record.city;

    %result{ 'continent_code' } = $_ with $record.continent_code;

    %result{ 'country' } = $_ with $record.country_name;

    %result{ 'country_code' } = $_ with $record.country_code;

    %result{ 'dma_code' } = $_ with $record.dma_code;

    %result{ 'latitude' } = .round( 0.000001 ) with $record.latitude;

    %result{ 'longitude' } = .round( 0.000001 ) with $record.longitude;

    %result{ 'postal_code' } = $_ with $record.postal_code;

    %result{ 'region' } = GeoIP_region_name_by_code( $record.country_code, $record.region )
        if defined $record.country_code and defined $record.region;

    %result{ 'region_code' } = $_ with $record.region;

    %result{ 'time_zone' } = GeoIP_time_zone_by_country_and_region( $record.country_code, $record.region )
        if defined $record.country_code and defined $record.region;

    return %result;
}

# locate by IPv4
multi method locate ( Str:D $ip! where / ^ [\d ** 1..3] ** 4 % '.' $ / ) {
    
    my $db = %!db{ GEOIP_CITY_EDITION_REV1 } or X::DatabaseMissing.new.throw( );
    
    return self!locate( GeoIP_record_by_addr( $db, $ip ) );
}

# locate by IPv6
multi method locate ( Str:D $ip! where / ^ [<xdigit> ** 0..4] ** 3..8 % ':' $ / ) {
    
    my $db = %!db{ GEOIP_CITY_EDITION_REV1_V6 } or X::DatabaseMissing.new.throw( );
    
    return self!locate( GeoIP_record_by_addr_v6( $db, $ip ) );
}
