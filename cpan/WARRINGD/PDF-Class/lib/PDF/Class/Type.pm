use v6;

role PDF::Class::Type {

    use PDF::Class::Loader;

    #| class/role must implement the 'type' method
    #| probably as an alias of /Type or another type
    #| descriminant field
## ++Rakudo 2018.11+ required. commented out for now.
##    method type {...}
## --Rakudo 2018.11+
}

role PDF::Class::Type::Subtyped does PDF::Class::Type {
    #| class/role must also implement the .subtype method
## ++Rakudo 2018.11+ required. commented out for now.
##    method subtype {...}
## --Rakudo 2018.11+
}
