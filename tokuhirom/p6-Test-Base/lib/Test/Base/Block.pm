use v6;

unit class Test::Base::Block;

has Str $.title;
has Hash $!data;

method new(Str $title, Hash $data) {
    self.bless()!initialize($title, $data);
}

method !initialize(Str $title, Hash $data) {
    $!title = $title;
    $!data = $data;
    self;
}

method EXISTS-KEY(Str $key) {
    $!data{$key}:exists
}

method AT-KEY(Str $key) {
    return $!data{$key};
}

method FALLBACK($name) {
    ::?CLASS.^add_method($name, method () { $!data{$name} });
    return $!data{$name};
}

method perl() {
    "Test::Base::Block.new({$.title.perl}, {$!data.perl})"
}

