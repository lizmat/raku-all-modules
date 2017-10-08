use v6.c;
unit module HandleSupplier:ver<0.0.1>;

sub supplier-for-handle(IO::Handle $io --> Supplier) is export {
    my $supplier = Supplier.new;
    my $supply = $supplier.Supply;
    $supply.tap(-> $v { $io.say($v) });
    return $supplier;
}

=begin pod

=head1 NAME

HandleSupplier - generate Supplier for an IO::Handle object

=head1 SYNOPSIS

  use HandleSupplier;

  my $supplier = supplier-for-handle($*ERR);
  # "hello\n" will be written to STDERR
  $supplier.emit("hello");

=head1 DESCRIPTION

HandleSupplier is a utility which provides a Supplier to emit messages to corresponding IO::Handle object.

=head1 AUTHOR

Asato Wakisaka <asato.wakisaka@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Asato Wakisaka

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
