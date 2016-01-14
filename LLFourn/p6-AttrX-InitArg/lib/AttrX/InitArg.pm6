my role InitArg {
    has $.init-arg is rw = self.name.substr(2);
    has $.null-init-arg is rw = False;
}

my role InitArgContainer {

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

        self;
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


multi sub trait_mod:<is>(Attribute $attr, :$init-arg!) is export {
    $attr does InitArg;

    given $init-arg {
        when Str:D   { $attr.init-arg = $_ }
        when not .so { $attr.null-init-arg = True }
    }

    # XXX: HACK -- it should use $attr.package but this doesn't work in roles atm
    # can't use .does here because we haven't composed it yet.
    $*PACKAGE.^add_role(InitArgContainer) unless $*PACKAGE.^roles_to_compose.first(InitArgContainer) !=== Nil;
}
