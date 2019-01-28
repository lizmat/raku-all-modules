use v6;
use Test;

sub install-distro ( Str:D $source, Str:D :$dest-dir = '.test-repo' --> Bool ) is export {
    $dest-dir.IO.mkdir;
    my %env = %*ENV;
    my @p6libs;
    @p6libs = .split(':') with %env<PERL6LIB>;
    %env<PERL6LIB> = (|@p6libs, './lib').join(':');
    my $proc = run "zef", "install", "--to=inst#$dest-dir", "--force", $source, :out, :err, :%env;
    unless $proc.exitcode == 0 {
        diag "'zef install' exit code: [{$proc.exitcode}]";
        diag "Module install output:";
        diag "> Stdout:";
        diag $proc.out.slurp;
        diag "> Stderr:";
        diag $proc.err.slurp;
    }
    CATCH {
        default {
            diag "Temporary repository installation failed: " ~ $_ ~ $_.backtrace;
            return False;
        }
    }
    return $proc.exitcode == 0;
}

sub wipe-repo ( Str:D :$dest-dir = '.test-repo' --> Bool ) is export {
    my $proc = run "rm", "-rf", $dest-dir;
    return $proc.exitcode == 0;
}

sub gen-plugins( %params --> Array ) is export {
    use OO::Plugin::Metamodel::PluginHOW;
    my $count = %params<count>;
    state $last-num = 0;
    my @list;
    for ^$count -> $i {
        my $*CURRENT-PLUGIN-CLASS;
        my %*CURRENT-PLUGIN-META;
        my $name = "P$last-num";
        my \ptype = OO::Plugin::Metamodel::PluginHOW.new_type( name => $name );

        my @roles;
        my $rlist := Nil;
        if %params<roles>{$i}:exists {
            $rlist := %params<roles>{ $i };
        } elsif %params<default-roles>:exists {
            $rlist := %params<default-roles>;
        }
        unless $rlist === Nil {
            if $rlist.DEFINITE and $rlist ~~ Positional {
                @roles := $rlist;
            } else {
                @roles[0] := $rlist;
            }
        }
        if @roles.elems {
            for @roles -> \r {
                ptype.HOW.add_role( ptype, r );
            }
        }

        @list[ $i ] := ptype;
        $last-num++;
    }

    # Build dependency metas for new plugins.
    my %pdeps;
    for %params<deps>.keys -> $mkey {
        given $mkey {
            when any <after before demand> {
                my %user-deps = %params<deps>{$_};
                for %user-deps.keys -> $idx {
                    my \ptype = @list[$idx];
                    %pdeps{ $idx }{$_} ∪= %user-deps{$idx}.map: { @list[$_].^name };
                }
            }
        }
    }

    for ^@list.elems {
        %pdeps{$_}<name> = @list[$_].^name ~ "." ~ $_;
        my %*CURRENT-PLUGIN-META = %pdeps{$_} // {};
        my \ptype = @list[$_].^compose;
    }

    @list
}

    # INIT {
    #     install-distro( './t/p6-Foo-Plugin-Test' ) or flunk "failed to install plugin distro";
    # }
