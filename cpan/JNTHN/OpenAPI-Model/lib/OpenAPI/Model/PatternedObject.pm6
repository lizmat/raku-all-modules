use v6;

role OpenAPI::Model::PatternedObject does Associative {
    has %.container;

    submethod TWEAK(*%args) {
        %!container = %args;
    }

    method kv()             { %!container.map({ slip .key, self!resolve(.value)}) }
    method pairs()          { gather {
                                    for %!container.kv -> $k, $v {
                                        take $k => self!resolve($v);
                                    }
                                }
                            }
    method keys()           { %!container.keys }
    method values()         { %!container.values.map({self!resolve($_)}) }
    method AT-KEY($key)     { self!resolve(%!container.AT-KEY($key)) }
    method EXISTS-KEY($key) { %!container.EXISTS-KEY($key) }
    method map($block)      { %!container.map($block) }

    method serialize() {
        %!container.map({ if .value ~~ Array {
                              .key => .value.map(*.serialize)
                          } else {
                              .key => .value.serialize
                          }}).Hash;
    }
}
