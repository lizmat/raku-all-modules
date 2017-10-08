use v6;

# CSS3 Namespaces Extension Module
# specification: http://www.w3.org/TR/2011/REC-css3-namespace-20110929/
#
class CSS::Module::CSS3::Namespaces::Actions {...}

class CSS::Module::CSS3::Namespaces { #:api<css3-namespace-20110929>

    rule at-decl:sym<namespace> {'@'(:i'namespace') <ns-prefix=.Ident>? [<url=.url-string>|<url>] ';' }
}

class CSS::Module::CSS3::Namespaces::Actions {

    use CSS::Grammar::AST :CSSObject;

    method at-decl:sym<namespace>($/) { make $.at-rule($/) }
}

