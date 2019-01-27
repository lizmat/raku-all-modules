use v6;

class X::Path::Router is Exception { }

class X::Path::Router::AmbiguousMatch is X::Path::Router { }

class X::Path::Router::AmbiguousMatch::PathMatch is X::Path::Router {
    has Str $.path;
    has @.matches;

    method message() {
        "Ambiguous match: path $!path could match any of "
            ~ @!matches.map({ .route.path }).sort.join(', ')
    }
}

class X::Path::Router::AmbiguousMatch::ReverseMatch is X::Path::Router::AmbiguousMatch {
    has Str @.match-keys;
    has @.routes;

    method message() {
        "Ambiguous path descriptor (specified keys "
        ~ @!match-keys.sort.join(', ')
        ~ "): could match paths "
        ~ @!routes.map(*.[0].path).sort.join(', ')
    }
}


class X::Path::Router::BadInclusion is X::Path::Router {
    method message() {
        "Path is either empty or does not end with /";
    }
}

class X::Path::Router::BadRoute is X::Path::Router {
    has Str $.path;

    method message() {
        "The path $!path will not work"
    }
}

class X::Path::Router::BadValidation is X::Path::Router::BadRoute {
    has Str $.validation;

    method message() {
        callsame() ~ ": Validation provided for component :$!validation, but no variable component for that name is found in the path"
    }
}

class X::Path::Router::BadSlurpy is X::Path::Router::BadRoute {
    method message() {
        callsame() ~ ": Slurpy components must be at the end of the path";
    }
}
