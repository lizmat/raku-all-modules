use v6.c;

use OpenAPI::Model::Reference;
use OpenAPI::Model::PatternedObject;
use JSON::Pointer;

class X::OpenAPI::Model::TypeMismatch is Exception {
    has $.name;
    has $.field;
    has @.expected;
    has $.got;

    method message() {
        "Schema for $!name object expects {@!expected.map(*.^name).join(', ')} for field '$!field', but got {$!got.^name}"
    }
}

class X::OpenAPI::Model::BadReference is Exception {
    has $.link;

    method message() {
        "When resolving reference encountered bad link: $!link"
    }
}

role OpenAPI::Model::Element [:%scalar, :%object, :$patterned = Nil, :$raw] {
    has $.model;
    has %.extensions;
    my %attr-lookup = ::?CLASS.^attributes(:local).map({ .name.substr(2) => $_ });

    method set-model($!model) {}

    method !resolve-schema($item) {
        return $item if $item !~~ Associative;
        $item.map(
            {
                if .key eqv '$ref' {
                    my $middle = self!resolve-reference(OpenAPI::Model::Reference.new(link => .value));
                    self!resolve-schema($middle);
                } elsif .value ~~ Associative|Positional {
                    .key => self!resolve-schema(.value);
                } else {
                    .key => .value;
                }
            }
        ).Hash;
    }

    method reference-check() {
        for %object.kv -> $k, $v {
            my $value = %attr-lookup{%object{$k}<attr> // $k}.get_value(self);
            given $value {
                when OpenAPI::Model::Reference {
                    self!resolve-reference($_);
                }
                when .^name.ends-with('Schema') {
                    self!resolve-schema(.container);
                }
                when OpenAPI::Model::PatternedObject {
                    .container.values.map({.reference-check});
                }
                when Positional {
                    .map({ .reference-check });
                }
                when Associative {
                    .values.map({.reference-check});
                }
                when OpenAPI::Model::Element {
                    .reference-check;
                }
            }
            CATCH {
                when X::AdHoc { next }
            }
        }
    }

    method !resolve($item, :$expect) {
        return $item if $item !~~ OpenAPI::Model::Reference;
        self!resolve-reference($item, :$expect);
    }

    method !resolve-reference(OpenAPI::Model::Reference $ref, :$expect) {
        given $ref.link {
            when .starts-with('#') {
                my @tokens = JSON::Pointer.parse(.substr(1)).tokens;
                my $root;
                if (self.^name.ends-with('OpenAPI')) {
                    $root = self;
                } else {
                    $root = $!model.root;
                }
                for @tokens -> $token {
                    my $t = $token.trans(['A'..'Z'] => [('a'..'z').map({'-' ~ $_})]);
                    $t .= substr(1) if $t.starts-with('-');
                    my $method = $root.^lookup($t);
                    if $method.defined {
                        $root = $root.$method;
                    } else {
                        if $root ~~ Associative {
                            with $root{$token} {
                                $root = $root{$token};
                            } else {
                                die X::OpenAPI::Model::BadReference.new(link => $ref.link);
                            }
                        } else {
                            die X::OpenAPI::Model::BadReference.new(link => $ref.link) unless $method.defined;
                        }
                    }
                }
                return $root if $root ~~ $expect;
                die X::OpenAPI::Model::BadReference.new(link => $ref.link);
            }
            when .split('#').elems == 2 {
                my ($ext, $rel) = .split('#');
                with $!model.external{$ext} {
                    return $_!resolve-reference(OpenAPI::Model::Reference.new(link => "#$rel"), :$expect);
                } else {
                    die X::OpenAPI::Model::BadReference.new(link => $ref.link);
                }
            }
            default {
                die "Not yet implemented: $_"
            }
        }
    }

    method !handle-refy($spec, $v, $model) {
        return $spec<type>.new(|$v) with $spec<raw>;
        if $spec<array> {
            return $v.map({
                    $_<$ref> ?? OpenAPI::Model::Reference.new(link => $_<$ref>)
                             !! $spec<type>.deserialize($_, $model)
                }).Array;
        } elsif $spec<hash> {
            return $v.map({
                    .key => .value<$ref> ?? OpenAPI::Model::Reference.new(link => .value<$ref>)
                                         !! $spec<type>.deserialize(.value, $model)
                }).Hash;
        } else {
            return $v<$ref> ?? OpenAPI::Model::Reference.new(link => $v<$ref>)
                            !! $spec<type>.deserialize($v, $model);
        }
    }

    method !handle-object($spec, $v, $model) {
        return self!handle-refy($spec, $v, $model) with $spec<ref>;
        return $spec<type>.new(|$v) with $spec<raw>;
        if $spec<array> {
            return $v.map({$spec<type>.deserialize($_, $model)}).Array;
        } elsif $spec<hash> {
            return $v.map({ .key => $spec<type>.deserialize(.value, $model) }).Hash;
        } else {
            if $spec.defined {
                return $spec<type>.deserialize($v, $model);
            } elsif $patterned ~~ OpenAPI::Model::Element {
                return $patterned.deserialize($v, $model);
            } elsif $patterned ~~ Array {
                with $v<$ref> {
                    return $patterned[1].new($v);
                } else {
                    return $patterned[0].deserialize($v, $model);
                }
            } elsif $patterned {
                return $v;
            }
        }
    }

    method deserialize($source, $model) {
        my %attrs;
        for $source.kv -> $k, $v {
            if $k (elem) %scalar.keys {
                %attrs{$k} = $v;
            } else {
                %attrs{$k} = self!handle-object(%object{$k}, $v, $model);
            }
        }
        my $new = self.new(|%attrs);
        $new.set-model($model);
        $new;
    }
    method serialize() {
        my %structure;
        for %scalar.kv -> $k, $v {
            my $value = %attr-lookup{%scalar{$k}<attr> // $k}.get_value(self);
            %structure{$k} = $value if $value.defined && $value !~~ [];
        }
        for %object.kv -> $k, $v {
            my $value = %attr-lookup{%object{$k}<attr> // $k}.get_value(self);
            given $value {
                when Array {
                    %structure{$k} = $value.map(*.serialize) if $value.elems > 0;
                }
                when Hash {
                    %structure{$k} = $value.map({.key => .value.serialize}).Hash if $value.elems > 0;
                }
                default {
                    %structure{$k} = $value.serialize if $value.defined;
                }
            }
        }
        %structure;
    }

    submethod BUILD(*%args where {
                           my $keys = .keys (-) (%scalar.keys (|) %object.keys);
                           $keys .= grep({ not .key.starts-with('x-') });
                           set $keys === set()
                       }) {
        for %args.kv -> $k, $v {
            my $normalized-name = (%scalar{$k} // %object{$k})<attr> // $k;
            my $attr = %attr-lookup{$normalized-name};
            if $k (elem) %scalar.keys {
                $attr.set_value(self, $v);
            } elsif $k (elem) %object.keys {
                my $spec = %object{$k};
                my &ref-cond = -> $_ { $_ ~~ OpenAPI::Model::Reference && $spec<ref> };
                my $cond = $spec<raw> ?? True !!
                           $spec<array> ?? so $v.map({$_ ~~ $spec<type> || &ref-cond($_)}).all !!
                           $spec<hash>  ?? so $v.values.map({$_ ~~ $spec<type> || &ref-cond($_)}).all !!
                           $v ~~ $spec<type> || &ref-cond($v);
                if $cond {
                    # TODO investigate return of AUTOGEN instead of method
                    # my $m = self.^lookup("set-" ~ $normalized-name);
                    # self.$m($v);
                    $attr.set_value(self, $v);
                } else {
                    die X::OpenAPI::Model::TypeMismatch.new(
                        name => ::?CLASS.^name, field => $k,
                        expected => $spec<type>, got => $v);
                }
            }
        }
    }
}
