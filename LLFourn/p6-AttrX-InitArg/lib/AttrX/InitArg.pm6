my role InitArg {
    has $.init-arg is rw = self.name.substr(2);
    has $.null-init-arg is rw = False;
}

my class InitArgContainer {

    method BUILDALL(@,%named) {

        # XXX: This should inlined into metaclass for performance
        for self.^attributes.grep(InitArg) -> $attr {
            if $attr.null-init-arg {
                %named{$attr.init-arg}:delete;
            }
            elsif %named{$attr.init-arg}:exists {
                $attr.set_value(self,%named{$attr.init-arg}:delete);
            }
            # delete any named matching the original attribute name
            %named{$attr.name.substr(2)}:delete if $attr.has_accessor;
        }

        callsame;
    }


    multi method perl {
        self.perlseen(self.^name, {
           my @attrs;
           for self.^attributes().flat -> $attr {
               my $name = do given $attr {
                   when InitArg {
                       when .null-init-arg { Nil }
                       default { .init-arg }
                   }
                   when .has_accessor { substr($attr.Str,2) }
               }
               if $name.defined {
                   @attrs.push: $name ~ ' => ' ~ $attr.get_value(self).perl
               }
           }
           self.^name ~ '.new' ~ ('(' ~ @attrs.join(', ') ~ ')' if @attrs)
        });
    }

    multi method gist {
        self.perlseen(self.^name, {
            my @attrs;
            for self.^attributes().flat.grep: { .has_accessor } -> $attr {
                my $name := substr($attr.Str,2);
                @attrs.push: $name ~ ' => ' ~ $attr.get_value(self).perl
            }
            self.^name ~ '.new' ~ ('(' ~ @attrs.join(', ') ~ ')' if @attrs)
        });
    }
}

# this is the only way I found to get the right answer
sub in-parents(Mu $pkg is raw) {
    if $pkg.HOW ~~ Metamodel::ParametricRoleGroupHOW {
        for $pkg.^candidates {
            return True if in-parents($_);
        }
    } else {
        # XXX:  you have to do both :local and without atm because of a bug
        return True if $pkg.^parents().first(InitArgContainer) !=== Nil;
        return True if $pkg.^parents(:local).first(InitArgContainer) !=== Nil;
        for $pkg.^roles_to_compose {
            return True if in-parents($_);
        }
    }

    False;
}

multi sub trait_mod:<is>(Attribute $attr, :$init-arg!) is export {
    $attr does InitArg;

    given $init-arg {
        when Str:D   { $attr.init-arg = $_ }
        when not .so { $attr.null-init-arg = True }
    }

    # XXX: HACK -- it should use $attr.package but this doesn't work in roles atm
    my Mu $pkg := $*PACKAGE;

    if not in-parents($pkg) {
        if $pkg.HOW !~~ Metamodel::ClassHOW {
            # XXX: HACK++, need to create > 1 inheritence distance when we have
            # a role. Otherwise 'class A does B does C { }' will die "already has parent"
            # if B and C both have init-args
            my $tmp := Metamodel::ClassHOW.new_type(:name<initArgHack>);
            $tmp.^add_parent(InitArgContainer);
            $tmp.^compose;
            $pkg.^add_parent($tmp,:hides);
        } else {
            $pkg.^add_parent(InitArgContainer);
        }
    }
}
