unit class Log::MDC;

my Log::MDC $instance;

has Str %!map;

method put(Str $key, Str $value) {
    %!map{$key} = $value;
    return self;
}

method get(Str $key) {
    return %!map{$key} || 'undef';
}

method delete(Str $key) {
    return %!map{$key}:delete;
}

method clear() {
    %!map = ();
    return self;
}
