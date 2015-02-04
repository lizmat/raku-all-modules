module IoC;

use IoC::Container;
use IoC::ConstructorInjection;
use IoC::BlockInjection;
use IoC::Literal;

my %containers;
my $container-name;

sub container($pair) is export {
    %containers{$pair.key} = IoC::Container.new(
        :name($pair.key),
    );

    $container-name = $pair.key;
    
    unless $pair.value ~~ Callable {
        die "Second param must be invocable";
    }

    $pair.value.();

    return %containers{$container-name};
}

sub contains(Block $sub) is export { return $sub }

sub service($pair) is export {
    my %params = ('name' => $pair.key);
    if $pair.value ~~ Str {
        %params<value> = $pair.value;
    }
    else {
        %params = (%params, $pair.value.pairs);
    }

    my $service;
    if %params<block>:exists {
        $service = IoC::BlockInjection.new(|%params);
    }
    elsif %params<type>:exists {
        $service = IoC::ConstructorInjection.new(|%params);
    }
    elsif %params<value>:exists {
        $service = IoC::Literal.new(|%params);
    }
    else {
        warn "Service {$pair.key} needs more parameters";
        return;
    }

    %containers{$container-name}.add-service($pair.key, $service);
}

=begin pod

=head1 NAME

IoC - Wire your application components together using inversion of control

=head1 SYNOPSIS

  use IoC;

  my $c = container 'myapp' => contains {

      service 'logfile' => 'logfile.txt';

      service 'logger' => {
          'class'        => 'MyLogger',
          'lifecycle'    => 'Singleton',
          'dependencies' => {'logfile' => 'logfile'},
      };

      service 'storage' => {
          'lifecycle' => 'Singleton',
          'block'     => sub {
              ...
              return MyStorage.new();
          },
      };

      service 'app' => {
          'class'        => 'MyApp',
          'lifecycle'    => 'Signleton',
          'dependencies' => {
              'logger'  => 'logger',
              'storage' => 'storage',
          },
      };

  };

  my $app = $c.resolve(service => 'app');
  $app.run();

=head1 DESCRIPTION

IoC is a port of stevan++'s Perl 5 module Bread::Board.

=head1 INVERSION OF CONTROL

Inversion of control is a way of keeping all your component creation logic in
one place. Instead of creating an object and explicitly pass it around everywhere,
one could just make a I<container> of all these components and allow the components to
cleanly interact with each other as I<services>.

=head1 EXPORTED FUNCTIONS

=item B<container>

Creates a new L<IoC::Container> object. In the block you create your services.

=item B<service>

Adds services to your container, bringing your components together. See
C<IoC::Service> for more information on this.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or post an issue
to http://github.com/jasonmay/perl6-ioc/

=head1 REFERENCE

=item L<IoC::Container> - Container of all your application components

=item L<IoC::Service> - Service representing a component in your application

=head1 ACKNOWLEDGEMENTS

=item Thanks to Stevan Little who is the original author of Perl 5's Bread::Board

=head1 AUTHOR

Jason May, <jason.a.may@gmail.com>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=end pod
