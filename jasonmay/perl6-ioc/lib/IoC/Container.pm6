class IoC::Container {
    has %!services;

    method add-service($name, $service) {
        if $service.^can('container') {
            $service.container = self;
        }
        $service.name = $name;
        %!services{$name} = $service;
    }

    method fetch($service-name) {
        return %!services{$service-name};
    }

    method resolve(:$service) {
        return self.fetch($service).get;
    }
};

=begin pod

=head1 NAME

IoC::Container

=head1 SYNOPSIS

my $c = IoC::Container.new();

  $c.add-service(
      'logfile', IoC::Literal.new(
          :lifecycle('Singleton'),
          :value('logfile.txt'),
      )
  );

  $c.add-service(
      'logger', IoC::ConstructorInjection.new(
          :class('Foo'),
          :lifecycle('Singleton'),
          :dependencies({
              'logfile' => 'logfile',
          }),
      )
  );

  $c.add-service(
      'storage', IoC::BlockInjection.new(
          :lifecycle('Singleton'),
          :block(sub {
              ...
              return MyStorage.new;
          }),
      )
  );

  $c.add-service(
      'app', IoC::BlockInjection.new(
          :class('MyApp'),
          :lifecycle('Singleton'),
          :dependencies({
              'logger'  => 'logger',
              'storage' => 'storage',
          }),
      )
  );

=head1 DESCRIPTION

Used in the container class for each component. See L<IoC::Container>
for an example of use of this class.

See L<IoC> for a more sweetened way to build your container.

=head1 METHODS

=item add-service(C<$name>, C<$service>)

Adds a service (L<IoC::Service> object) to your container

=item fetch('<service>')

Returns the service provided by the string.

=item resolve(service => '<service>')

Returns the object the service generates (equivalent to C<fetch('<service>').get()>)

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or post an issue
to http://github.com/jasonmay/perl6-ioc/

=head1 REFERENCE

=item L<IoC::Service>

=head1 AUTHOR

Jason May, <jason.a.may@gmail.com>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=end pod
