use v6;

module Clean {

  role Cleanable is export {
    method clean() {
      ...
    }
  }

  sub clean( Cleanable $o, &block ) is export {
    &block($o) if &block.defined;
    $o.clean   if $o.defined;
  }
}

=begin pod

=head1 NAME

Clean - Scoped object oriented automatic cleanup

=head1 SYNOPSIS

    use v6;
    use Clean;

    class Foo does Cleanable {
      method clean {
        say "clean called!";
      }
    }

    clean Foo.new, -> $o { say $o.perl if $o.defined; }

=head1 DESCRIPTION

Provides a routine `clean` that takes an object and an anonymous code block
which takes an object that does `Cleanable`. This basically ensures that your
objects can be cleaned after your code block has finished running. Thus it
provides an object-oriented `clean` method (aka destructor).

=head1 AUTHOR

Ahmad M. Zawawi, azawawi

=head1 LICENSE

MIT License

=end pod
