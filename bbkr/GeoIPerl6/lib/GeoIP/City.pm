unit class GeoIP::City;

use GeoIP;

has GeoIP %!db;

class X::DatabaseMissing is Exception is export { };

submethod BUILD ( Str :$directory where { .defined.not or .IO ~~ :d } ) {
    
    # change default directory
    GeoIP_setup_custom_directory( $directory ) if defined $directory;
    
    # initialize GeoIPCity.dat and GeoIPCityv6.dat databases
    for GEOIP_CITY_EDITION_REV1, GEOIP_CITY_EDITION_REV1_V6 {
        
        # check if database is available
        next unless GeoIP_db_avail( +$_ );
        
        # open database
        %!db{$_} = GeoIP_open_type( +$_, 0 );
        
        # set UTF-8 encoding
        GeoIP_set_charset( %!db{$_}, 1 );
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

    %result{'latitude'} = $record.latitude.round(0.000001)
        if defined $record.latitude;

    %result{'longitude'} = $record.longitude.round(0.000001)
        if defined $record.longitude;

    %result{'postal_code'} = $record.postal_code
        if defined $record.postal_code;

    %result{'region'} = GeoIP_region_name_by_code( $record.country_code, $record.region )
        if defined $record.country_code and defined $record.region;

    %result{'region_code'} = $record.region
        if defined $record.region;

    %result{'time_zone'} = GeoIP_time_zone_by_country_and_region( $record.country_code, $record.region )
        if defined $record.country_code and defined $record.region;

    return %result;
}

# locate by IPv4
multi method locate ( Str:D $ip! where / ^ [\d ** 1..3] ** 4 % '.' $ / ) {
    
    my $db = %!db{GEOIP_CITY_EDITION_REV1} or X::DatabaseMissing.new.throw( );
    
    return self!locate( GeoIP_record_by_addr( $db, $ip ) );
}

# locate by IPv6
multi method locate ( Str:D $ip! where / ^ [<xdigit> ** 0..4] ** 3..8 % ':' $ / ) {
    
    my $db = %!db{GEOIP_CITY_EDITION_REV1_V6} or X::DatabaseMissing.new.throw( );
    
    return self!locate( GeoIP_record_by_addr_v6( $db, $ip ) );
}
