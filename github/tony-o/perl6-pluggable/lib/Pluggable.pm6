unit role Pluggable;

use JSON::Fast;
use File::Find;

=begin pod

=head1 NAME

Pluggable - dynamically find modules or classes under a given namespace

This is a modified version orginally based on https://github.com/tony-o/perl6-pluggable.

=head1 SYNOPSIS

Given a set of plugins in your library search path:

    a::Plugins::Plugin1
    a::Plugins::Plugin2
    a::Plugins::PluginClass1::PluginClass2::Plugin3

And an invocation of Pluggable like this:

    use Pluggable; 

    class a does Pluggable {
        method listplugins () {
            @($.plugins).map({.perl}).join("\n").say;
        }
    }

    a.new.listplugins;

The following output would be produced:

    a::Plugins::Plugin1
    a::Plugins::Plugin2
    a::Plugins::PluginClass1::PluginClass2::Plugin3

=head1 FEATURES

=item Role as well as procedural interface
=item Custom module name matching
=item Finding plugins outside of the current modules namespace 

=head1 DESCRIPTION

=head2 Object-Oriented Interface

When "doing" the Pluggable role, a class can use the "plugins" method:

    $.plugins(:$base = Nil, :$plugins-namespace = 'Plugins', :$name-matcher = Nil)

=head3 :$base (optional)

The base namespace to look for plugins under, if not provided then the namespace from which 
pluggable is invoked is used.

=head3 :$plugins-namespace (default: 'Plugins')

The name of the namespace within I<$base> that contains plugins.

=head3 :$name-matcher (optional)

If present, the name of any module found will be compared with this and only returned if they match.

=head2 Procedural Interface

In a similar fashion, the module can be used in a non-OO environment, it exports
a single sub:

    plugins($base, :$plugins-namespace = 'Plugins', :$name-matcher = Nil)

=head3 $base (required)

The base namespace to look for plugins under. Unlike in the OO case, this is required in the procedural interface.

=head3 :$plugins-namespace (default: 'Plugins')

The name of the namespace within I<$base> that contains plugins.

=head3 :$name-matcher (optional)

If present, the name of any module found will be compared with this and only returned if they match.

=head1 LICENSE

Released under the Artistic License 2.0 L<http://www.perlfoundation.org/artistic_license_2_0>

=head1 AUTHORS

=item Robert Lemmen L<robertle@semistable.com>
=item tony-o L<https://www.github.com/tony-o/>

=end pod

my sub match-try-add-module($module-name, $base, $namespace, $name-matcher, @result) {
    if (   ($module-name.chars > "{$base}::{$namespace}".chars)
        && ($module-name.starts-with("{$base}::{$namespace}")) ) {

        if ((!defined $name-matcher) || ($module-name ~~ $name-matcher)) {
            try {
                CATCH {
                    default {
                         say .WHAT.perl, do given .backtrace[0] { .file, .line, .subname }
                    }
                }
                require ::($module-name);
                @result.push(::($module-name));
            }
        }
    }
}

my sub find-modules($base, $namespace, $name-matcher) {
    my @result = ();

    for $*REPO.repo-chain -> $r {
        given $r.WHAT {
            when CompUnit::Repository::FileSystem { 
                my @files = find(dir => $r.prefix, name => /\.pm6?$/);
                @files = map(-> $s { $s.substr($r.prefix.chars + 1) }, @files);
                @files = map(-> $s { $s.substr(0, $s.rindex('.')) }, @files);
                @files = map(-> $s { $s.subst(/\//, '::', :g) }, @files);
                for @files -> $f {
                    match-try-add-module($f, $base, $namespace, $name-matcher, @result);
                }
            }
            when CompUnit::Repository::Installation {
                # XXX perhaps $r.installed() could be leveraged here, but it
                # seems broken at the moment
                my $dist_dir = $r.prefix.child('dist');
                if ($dist_dir.?e) {
                    for $dist_dir.IO.dir.grep(*.IO.f) -> $idx_file {
                        my $data = from-json($idx_file.IO.slurp);
                        for $data{'provides'}.keys -> $f {
                            match-try-add-module($f, $base, $namespace, $name-matcher, @result);
                        }    
                    }
                }
            }
            # XXX do we need to support more repository types?
        }
    }
    return @result.unique.Array;
}

method plugins(:$base = Nil, :$plugins-namespace = 'Plugins', :$name-matcher = Nil) {
    my $class = "{$base.defined ?? $base !! ::?CLASS.^name}";
    return find-modules($class, $plugins-namespace, $name-matcher);
}

sub plugins($base, :$plugins-namespace = 'Plugins', :$name-matcher = Nil) is export {
    return find-modules($base, $plugins-namespace, $name-matcher);
}

