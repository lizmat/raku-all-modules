use v6;

use Web::Cache::Memory;
# TODO
# use Web::Cache::Disk;
# use Web::Cache::Memcached;
# use Web::Cache::Redis;

unit module Web::Cache:ver<0.000001>;

# Generate full module name from $backend shortname
sub mod-name(Str $backend --> Str) {
    return 'Web::Cache::' ~ $backend.tc;
}

# Set a key / value in the cache
sub cache-set($store, $module, Str $key, Str $content --> Str) {
    return &::($module ~ '::set')($store, $key, $content);
}

# Get a key from the cache
sub cache-get($store, Str $module, Str $key --> Str) {
    return &::($module ~ '::get')($store, $key);
}

# Remove a key from the cache
sub cache-remove($store, Str $module, Str $key --> Str) {
    return &::($module ~ '::remove')($store, $key);
}

# Clear the entire cache
sub cache-clear($store, Str $module --> Array) {
    return &::($module ~ '::clear')($store);
}

# Build a new sub that provides interface to cache 
# backend module and actions.
sub create-store-sub(:$backend_module, :%config --> Block) {

    my $store_instance = &::($backend_module ~ '::load')(%config);

    return -> Callable $content?,                  # Callback that generates the content for the cache
              Mu:D     :$store  = $store_instance, # Actual cache instance
              Str:D    :$module = $backend_module, # Module that manages cache type
                       :$key,                      # Key for cache ID
                       :$expires_in,               # Expire the provided key in n minutes
              Bool     :$clear  = False,           # Clears all keys from cache
              Bool     :$remove = False --> Str {  # When passed with key, removes key from cache
        
        # Remove a key or clear everything
        when $clear  { cache-clear( $store, $module ).Str }
        when $remove { cache-remove( $store, $module, $key ) }

        # Otherwise, store / return key from cache
        cache-get( $store, $module, $key ) || cache-set( $store, $module, $key, $content.() );
    }
}

# Cache store initialization
sub cache-create-store(Int :$size    = 1024,
                       Str :$backend = 'memory' --> Block) is export {

    my $module = mod-name($backend);
    my %config = size    => $size,
                 backend => $backend;
    return create-store-sub(backend_module => $module, config => %config);
}; 

=begin pod

=head1 NAME

Web::Cache - Web framework independant caching module.

=head1 SYNOPSIS

=begin code 
use Web::Cache;
my &memory-cache = cache-create-store( size    => 2048,
                                       backend => 'memory' );
memory-cache(key => $cache-key, {
    my $data = expensive-db-query(...);
    expensive-template-step($data);
});

memory-cache( key => $fancy_cache_key, :remove );

memory-cache( :clear );
=end code

=head1 DESCRIPTION

The goal of this module is to provide a variety of cache backend
wrappers and utilities that simplify caching tasks within the 
context of a web application.

=head1 COPYRIGHT

This module is Copyright (c) 2017 Sam Morrison. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the Artistic License 2.0.

=head1 WARRANTY

This is free software. IT COMES WITHOUT WARRANTY OF ANY KIND.

=head1 ISSUES

See this github repo issues tracker:

   https://github.com/scmorrison/perl6-Web-Cache/issues

=head1 AUTHORS

Sam Morrison

=end pod

# vim: ft=perl6 sw=4 ts=4 st=4 sts=4 et
