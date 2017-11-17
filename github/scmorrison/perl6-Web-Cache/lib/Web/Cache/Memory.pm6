use v6;
use Cache::LRU;

unit module Web::Cache::Memory;

our sub load(%config) {
    return Cache::LRU.new( size => %config<size> );
}

our sub set($store, $key, $content) {
    $store.set($key, $content);
}

our sub get($store, $key) {
    $store.get($key);
}

our sub remove($store, $key) {
    $store.remove($key);
}

our sub clear($store) {
    $store.clear;
}
