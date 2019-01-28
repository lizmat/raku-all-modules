use v6.c;

# Since we cannot export a proto sub trait_mod:<is> with "is export", we
# need to do this manually with an EXPORT sub.  So we create a hash here
# to be set in compilation of the mainline and then return that in the
# EXPORT sub.
my %EXPORT;

# Save the original trait_mod:<is> candidates, so we can pass on through
# all of the trait_mod:<is>'s that cannot be handled here.
BEGIN my $original_trait_mod_is = &trait_mod:<is>;

module Hash::Restricted:ver<0.0.5>:auth<cpan:ELIZABETH> {

    sub nono($what, \map, \keys) is hidden-from-backtrace {
        die "Not allowed to $what {map.VAR.name}<{keys}>";
    }

    # The role to be applied if not a specific set of keys was given.
    # This will set the allowable keys after the first initialization.
    my role restrict-current {
        has %!allowed;

        method AT-KEY(::?CLASS:D: \key) is hidden-from-backtrace {
            %!allowed.EXISTS-KEY(key)
              ?? (nextsame)
              !! nono("access non-existing",self,key)
        }
        method ASSIGN-KEY(::?CLASS:D: \key, \value) is hidden-from-backtrace {
            %!allowed.EXISTS-KEY(key)
              ?? (nextsame)
              !! nono("create",self,key)
        }
        method BIND-KEY(::?CLASS:D: \key, \value) is hidden-from-backtrace {
            %!allowed.EXISTS-KEY(key)
              ?? (nextsame)
              !! nono("create",self,key)
        }
        method STORE(
          \to_store, :initialize(:$INITIALIZE)
        ) is hidden-from-backtrace {
            callsame;
            if $INITIALIZE {
                %!allowed = self.keys.map: * => True;
            }
            else {
                if self (-) %!allowed -> $extra {
                    self{$extra.keys}:delete;
                    nono("store",self,$extra.keys)
                }
            }
            self
        }
    }

    # The role to be applied with a given set of keys.
    my role restrict-given[%allowed] {
        method AT-KEY(::?CLASS:D: \key) is hidden-from-backtrace {
            %allowed.EXISTS-KEY(key)
              ?? (nextsame)
              !! nono("access non-existing",self,key)
        }
        method ASSIGN-KEY(::?CLASS:D: \key, \value) is hidden-from-backtrace {
            %allowed.EXISTS-KEY(key)
              ?? (nextsame)
              !! nono("create",self,key)
        }
        method BIND-KEY(::?CLASS:D: \key, \value) is hidden-from-backtrace {
            %allowed.EXISTS-KEY(key)
              ?? (nextsame)
              !! nono("create",self,key)
        }
        method STORE(\to_store) is hidden-from-backtrace {
            callsame;
            if self (-) %allowed -> $extra {
                self{$extra.keys}:delete;
                nono("store",self,$extra.keys)
            }
            self
        }
    }

    # Manually mark this proto for export
    %EXPORT<&trait_mod:<is>> := proto sub trait_mod:<is>(|) {*}

    # Handle the "is restricted" / is restricted(Bool:D) cases
    multi sub trait_mod:<is>(Variable:D \v, Bool:D :$restricted!) {
        die "Can only apply 'is restricted' on a Map, not a {v.var.WHAT}"
          unless v.var.WHAT ~~ Map;
        my $name = v.var.^name;
        if $restricted {
            trait_mod:<does>(v, restrict-current);
            v.var.WHAT.^set_name("$name\(restricted)");
        }
    }

    # Handle the "is restricted<a b c>" case
    multi sub trait_mod:<is>(Variable:D \v, :@restricted!) {
        die "Can only apply 'is restricted' on a Map, not a {v.var.WHAT}"
          unless v.var.WHAT ~~ Map;
        my %restricted = @restricted.map: * => True;
        my $name = v.var.^name;
        trait_mod:<does>(v, restrict-given[%restricted]);
        v.var.WHAT.^set_name("$name\(restricted)");
    }

    # Make sure we handle all of the standard traits correctly
    multi sub trait_mod:<is>(|c) { $original_trait_mod_is(|c) }
}

sub EXPORT { %EXPORT }

=begin pod

=head1 NAME

Hash::Restricted - trait for restricting keys in hashes

=head1 SYNOPSIS

  use Hash::Restricted;

  my %h is restricted = a => 42, b => 666;
  %h<c> = 317;  # dies

  my %h is restricted<a b>;
  %h<a> = 42;
  %h<b> = 666;
  %h<c> = 317;  # dies

=head1 DESCRIPTION

Hash::Restricted provides a C<is restricted> trait on C<Map>s and C<Hash>es
as an easy way to restrict which keys are going to be allowed in the C<Map> /
C<Hash>.

If you do not specify any keys with C<is restricted>, it will limit to the
keys that were specified when the C<Map> / C<Hash> was initialized.

If you B<do> specify keys, then those will be the keys that will be allowed.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Hash-Restricted .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
