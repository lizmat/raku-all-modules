use JSON::Stream::State;
use JSON::Stream::Type;

#my $*DEBUG = True;
sub debug(|c) { note |c if $*DEBUG }
constant @stop-words = '{', '}', '[', ']', '"', ':', ',';

proto parse(State:D $state, Str $chunk --> State:D) is pure is export { * }

multi parse($_ where .type ~~ [string, key].none, $chunk where * ~~ @stop-words.none) {
    debug "parse generic";
    .cond-emit-concat: $chunk;
    .clone: :cache(.remove-from-cache: $chunk)
}

# STRING
# string start
multi parse($_ where .type ~~ [string, object, key].none, '"') {
    debug "parse string start";
    .clone: :types(.add-type: string), :cache(.add-to-cache: '"')
}

# string body
multi parse($_ where .type ~~ string, $chunk) {
    debug "parse string body";
    .clone: :cache(.add-to-cache: $chunk)
}

# string end
multi parse($_ where .type ~~ string, '"') {
    debug "parse string end";
    .cond-emit-concat: '"';
    .clone: :types(.pop-type), :cache(.remove-from-cache: '"')
}

# OBJECT
# object start
multi parse($_, '{') {
    debug "parse object start";
    .clone: :types(.add-type: object), :cache(.add-to-cache: '{')
}

# object key start
multi parse($_ where .type ~~ object, '"') {
    debug "parse object key start";
    .clone: :types(.add-type: key), :cache(.add-to-cache: '"')
}

# object key body
multi parse($_ where .type ~~ key, $key where * ~~ @stop-words.none) {
    debug "parse object key body";
    .clone: :cache(.add-to-cache: $key), :path[.add-path: $key]
}

# object key end
multi parse($_ where .type ~~ key, '"') {
    debug "parse object key end";
    .clone: :type(.pop-type), :cache(.add-to-cache: '"', :path(.pop-path))
}

# object key sep
multi parse($_ where .type ~~ key, ':') {
    debug "parse object key sep";
    .clone: :types(.change-type: value), :cache(.add-to-cache: ':', :path(.pop-path))
}

# object sep
multi parse($_ where .type ~~ value, ',') {
    debug "parse object sep";
    .clone: :types(.pop-type), :cache(.add-to-cache: ','), :path(.pop-path)
}

# object end
multi parse($_ where .type ~~ value | object, '}') {
    debug "parse object end";
    .cond-emit-concat: '}', :path(.pop-path);
    .clone: :types(.pop-type: .type ~~ object ?? 1 !! 2), :cache(.remove-from-cache: '}', :path(.pop-path)), :path(.pop-path)
}

# ARRAY
# array start
multi parse($_, '[') {
    debug "parse array start";
    .clone: :types(.add-type: array), :cache(.add-to-cache: '['), :path(.add-path: "0")
}

# array sep
multi parse($_ where .type ~~ array, ',') {
    debug "parse array sep";
    .clone: :cache(.remove-from-cache: ','), :path(.increment-path)
}

# array end
multi parse($_ where .type ~~ array, ']') {
    debug "parse array end";
    .cond-emit-concat: ']', :path(.pop-path);
    .clone: :types(.pop-type), :cache(.remove-from-cache: ']'), :path(.pop-path)
}

