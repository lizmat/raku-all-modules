use v6;

unit module Cofra::IOC;

use X::Cofra::Error;

role Dependency {
    method resolve(Any:D $obj, :$name --> Any) {
        $*IOC.get($name);
    }
}

class NamedDependency does Dependency {
    has $.name;

    method resolve(Any:D $obj --> Any) {
        try $obj."$!name"()
    }
}

class Acquirer {
    has $.root;

    multi method get($name --> Any) {
        if $!root.can($name) {
            $!root."$name"();
        }
        else {
            die X::Cofra::Error::IOC::Acquisition.new;
        }
    }
}

my role HasConstructionArgs {
    method construction-args(Any:D $container --> Capture:D) { ... }

    method resolved-construction-args(Any:D $container, :$attribute, :$name --> Capture:D) {
        my \raw = self.construction-args(
            $container,
            :$attribute,
            :$name,
        );

        my sub resolver($_, :$name, :$pos) {
            when Dependency {
                .resolve($container, :$name, :$pos);
            }
            default { $_ }
        }

        my (@list, %hash);
        @list = raw.list.kv.map(-> $pos, $v {
            resolver($v, :$pos)
        });
        %hash = raw.hash.kv.map(-> $name, $v {
            $name => resolver($v, :$name)
        });

        Capture.new(:@list, :%hash);
    }
}

my role HasExplicitConstructionArgs[Capture $args] does HasConstructionArgs {
    method construction-args(Any:D $container --> Capture:D) { $args }
}

my role HasCallableConstructionArgs[&args] does HasConstructionArgs {
    method construction-args(Any:D $container, :$attribute, :$name --> Capture:D) {
        $container.&args(:$attribute, :$name);
    }
}

proto dep(|) is export { * }
multi dep(--> Dependency:D) { Dependency.new }
multi dep(Str:D $name --> Dependency:D) {
    NamedDependency.new(:$name);
}

multi trait_mod:<is> (Attribute $a, Capture :$construction-args) {
    $a does HasExplicitConstructionArgs[$construction-args];
}

multi trait_mod:<is> (Attribute $a, :&construction-args) {
    $a does HasCallableConstructionArgs[&construction-args];
}

multi trait_mod:<is> (Attribute $a, :$construction-args) {
    my \c = Capture.new(hash => $construction-args);
    $a does HasExplicitConstructionArgs[c];
}

my role PostInitializer[&do-init] {
    method post-initialize(Any $obj, Attribute:D :$attribute, Str:D :$name) {
        do-init($obj, :$attribute, :$name);
    }
}

my role LazyConstruction[Str:D $trait] {
    method trait-name(--> Str:D) { $trait }

    method lazy-builder(--> Method:D) { ... }

    method compose(Mu $package) {
        callsame;

        my &builder = &.lazy-builder;

        my $attribute = self;
        if $attribute.has_accessor {

            my $name = self.name.substr(2);
            $package.^method_table.{$name}.wrap(
                method () {
                    my $*IOC = Acquirer.new(root => self);

                    # TODO It would be nice if we had a guarantee that this
                    # just ran once per object. As far as I know, though,
                    # there's no means for creating weak references or
                    # something like Java's WeakHashRef, which feels
                    # necessary to do that in a way that won't leak memory.
                    without $attribute.get_value(self) {
                        my Capture $args;
                        if $attribute ~~ HasConstructionArgs {
                            $args = $attribute.resolved-construction-args(
                                self,
                                :$attribute,
                                :$name,
                            );
                        }
                        else {
                            $args .= new;
                        }

                        my $obj = self.&builder(
                            :$attribute,
                            :$name,
                            :$args,
                        );

                        if $attribute ~~ PostInitializer {
                            $attribute.post-initialize($obj, :$name, :$attribute);
                        }

                        $attribute.set_value(
                            self,
                            $obj
                        );
                    }

                    callsame;
                }
            );
        }

    }
}

my role Factory[&factory] does LazyConstruction['factory'] {
    method lazy-builder(--> Method:D) { &factory }
}

class GLOBAL::X::Cofra::IOC is X::Cofra::Error { }
class GLOBAL::X::Cofra::IOC::Retrait is X::Cofra::IOC { }
class GLOBAL::X::Cofra::IOC::Acquisition is X::Cofra::IOC { }

my sub check-for-lazy-construction-trait(Attribute $a, Str:D $trait) {
    if $a ~~ LazyConstruction {
        die X::Cofra::IOC::Retrait.new(
            cause => "Attribute $a.name() already has construction trait $a.trait-name(). It is not possible to add trait $trait too.",
        );
    }
}

# This is basically a poor person's IOC helper. It's not good but it will serve
# my purposes as an MVP solution in the short term.
multi trait_mod:<is> (Attribute $a, :$factory!) is export {
    check-for-lazy-construction-trait($a, 'factory');
    $a does Factory[$factory];
}

my role Constructed[Mu $c] does LazyConstruction['constructed'] {
    method lazy-builder(--> Method:D) {
        anon method constructed-lazy-builder(Capture :$args, :$attribute, :$name) {
            my $class = $c;
            if $class ~~ Dependency {
                $class .= resolve(self, :$attribute, :$name);
            }

            if $class =:= Mu || ($class ~~ Bool && $class == True) {
                $class = $attribute.type;
                $class.new(|$args);
            }
            else {
                $class.new(|$args);
            }
        }
    }
}

multi trait_mod:<is> (Attribute $a, Mu :$constructed!) is export {
    check-for-lazy-construction-trait($a, 'constructed');

    $a does Constructed[$constructed];
}

multi trait_mod:<is> (Attribute $a, :&post-initialized!) {
    $a does PostInitializer[&post-initialized];
}

=begin pod

=head1 NAME

Cofra::IOC - the inversion of control part

=head1 SYNOPSIS

    unit class MyApp::Bodge;

    use Cofra::IOC;
    use DB-Connector-Thingy;

    has Str $.database is required;

    has DB-Connector-Thingy $.dbh is constructed is construction-args({
        database => dep,
    });

    has $.lazy-factory-item is factory(&build-lazy-factory-item);

    method build-lazy-factory-item() {
        use Lazy::Item;
        Lazy::Item.new;
    }

=head1 DESCRIPTION

This module provides tools to turn your application completely upside-down. It provides governance for the people by the people. Down with monarchs and the false patriarchy they represent!

This module provides tools for configuring your application using inversion of control (IOC) patterns and dependency injection. These tools are very immature and have only recently survived the revolution. However, they are workable as-is and this is a pattern I've developed against before, so I believe the API is likely to be relatively stable.

=head1 ROUTINES

=head2 trait is factory

    multi trait_mod:<is> (Attribute $a, :&factory!)

This is the simplest of the lazy-constructor traits. Provided with a factory method, it will build the value of the attribute at the moment the attribute is first requested. The method will be called with it's invocant set to the object that is operating at the IOC container.

The factory is called as follows:

    factory(
        name      => $name,
        attribute => $attribute,
        args      => \(...),
    );

The C<name> is the name of the attribute without the sigils or twigils on the front.

The C<attribute> is the C<Attribute> object for the attribute that is being constructed.

The C<args> is a C<Capture> containing arguments being passed. To pass arguments you will need to employ dependency injection.

=head2 trait is constructed

    multi trait_mod:<is> (Attribute $a, Mu $class!)

This lazy constructor will lazily build the attribute using the C<.new> method of the class. This trait can either be passed naked or with a class name:

    has Hash $.config is constructed;
    has Cofra::Logger $.logger is constructed(Cofra::Logger::Screen);

With no class, it will use the attribute's type to infer the class. With the class, it will use the named class.

You can also pass a dependency to inject the class name as a dependency:

    method app-class { MyApp }
    has Cofra::App $.app is constructed(dep('app-class'));

=head2 trait is construction-args

    multi trait_mod:<is> (Attribute $a, Capture :$construction-args!)
    multi trait_mod:<is> (Attribute $a, :&construction-args!)
    multi trait_mod:<is> (Attribute $a, :%construction-args!)

This provides the tooling to perform dependency injection by passing arguments to the lazy constructor. This works by either passing a C<Capture> object, a hash of named arguments, or a routine that returns a C<Capture>.

If you pass a C<Capture>, it may contain whatever literal values you need to pass as well as dependencies declared using C<dep>. These will be resolved just before calling the lazy constructor.

If you pass a hash, it is treated exactly the same way as the capture, but only with named arguments.

If you pass a routine, it is called with the C<$attribute> being constructed and the C<$name> of the attribute withtout sigils and twigils on the front, both as named arguments. It is expected that the method will return a C<Capture>.

=head2 sub dep

    multi sub dep()
    multi sub dep(Str:D $name)

This is a specialized subroutine that should only be used within the parts of the IOC tooling that are able to handle dependencies.

When a dependency is resolved, it will be resolved by calling a method with no arguments on the IOC container. If a C<$name> is passed, it will be the named method. If not name is given, the name of the named argument being set will be used as the name to call.

=head2 trait is post-initialized

    multi trait_mod:<is> (Attribute $a, :&post-initialized!)

After the lazy constructor is finished, this trait can be attached to the attribute to perform some followup initializaiton. The C<&post-initialized> routine will be called as follows:

    $obj.post-initialized(:$attribute, :$name);

Here the C<self> is the newly constructed object that will be assigned to the attribute. The C<$attribute> is the C<Attribute> being set and C<$name> is the name of the attribute with the sigils and twigils left off the front.

=head1 CAVEATS

This code mucks around in certain metamodel bits that have not gotten as much TLC for bug squashing as they need. As such, you might get mysterious errors when using this, especially the annoying:

    Cannot invoke this object (REPR: Null; VMNull)

This generally indicates that Rakudo has tried to swallow its own fist and choked on it. I recommend putting this pragma line at the top of your IOC classes if this happens to you:

    no precompilation;

Unfortunately, with that Rakudo will compile this code every time your program runs. It also means that whatever other optimizier and other bits that run only during precompilation won't run to break this code and cause inexplicable errors.

The other alternative is to drop using IOC for whatever bits are causing Rakudo to die horrifically or track down the bugs and patch Rakudo. I'm not much of a language implementer myself, so while I did once patch Rakudo, I haven't really made a habit of it. I don't even know where to start in tracking down a bug like this and really, I don't have time. If I need to spend that time, I'll just switch languages or switch how I'm using this one.C<< </rant> >>

=end pod
