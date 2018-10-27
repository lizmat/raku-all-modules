use v6;
use AWS::Pricing;

unit package AWS::Pricing::CLI;

sub USAGE is export {
    say q:to/END/;
    aws-pricing - Pull AWS Pricing data from the AWS Pricing API
     
    USAGE
     
        aws-pricing services
        aws-pricing service-offers <service_code>;
        aws-pricing service-codes
        aws-pricing regions 
        aws-pricing version
    
    COMMANDS
    
        services           Return Service Offer index
        service-offers     Return Service Offers for specific service code and/or region
        service-codes      List all valid service codes
        regions            List all valid regions
        version            Display aws-pricing version
    
    OPTIONS
    
        service-offers specific
    
        --format           json|csv Default json
        --region           Filter AWS region to pull offer data
        --header           Display the CSV header. Disabled by default
    
    FLAGS
    
        --refresh          Force cache_dir refresh
        --cache_path       Path to cache path service offer files (Default ~/.aws-pricing)
        --quiet            No output, cache only (services, service-offers)

    END
}

multi MAIN(
    'services', 
    Bool :$refresh    = False,
    Str  :$cache_path = "$*HOME/.aws-pricing",
    Bool :$quiet      = False
) is export {
    # List all Service Offer indexes
    AWS::Pricing::services(
        config => AWS::Pricing::config(
            refresh    => $refresh,
            cache_path => $cache_path
        )
    ).&{ .say unless $quiet };
}

multi MAIN(
    'service-offers', 
    Str  $service_code,
    Bool :$refresh      = False,
    Bool :$header       = False,
    Str  :$cache_path   = "$*HOME/.aws-pricing",
    Str  :$region       = '',
    Str  :$format where { $format ~~ 'json'|'csv'} = 'json',
    Bool :$quiet        = False
) is export {
    # List current offers for specific service
    AWS::Pricing::service-offers(
        display_header  => $header,
        service_code    => $service_code,
        format          => $format,
        region          => $region,
        config          => AWS::Pricing::config(
            refresh     => $refresh,
            cache_path  => $cache_path
        )
    ).&{ .say unless $quiet };
}

multi MAIN(
    'service-codes'
    --> Seq 
) is export {
    # List all Service Offer indexes
    AWS::Pricing::service-codes.map({ .say });
}

multi MAIN(
    'regions'
    --> Seq
) is export {
    # List all Service Offer indexes
    AWS::Pricing::regions.map({ .say });
}

multi MAIN('version') is export {
    say "aws-pricing {AWS::Pricing.^ver}";
}
