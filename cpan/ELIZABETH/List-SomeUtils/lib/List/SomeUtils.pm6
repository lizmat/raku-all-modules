use v6.c;

module List::SomeUtils:ver<0.0.4>:auth<cpan:ELIZABETH> {
    use List::MoreUtils;

    BEGIN {
        trait_mod:<is>(
          (List::SomeUtils::{.key} = .value),   # make it available externally
          :SYMBOL(.key),                        # use this name, not its own
          :export(:all)                         # make it export with :all
        ) for List::MoreUtils::EXPORT::all::.grep(*.key.starts-with("&"))
    }
}

sub EXPORT(*@args, *%_) {
    if @args {
        my $imports := Map.new( |(EXPORT::all::{ @args.map: '&' ~ * }:p) );
        if $imports != @args {
            die "List::MoreUtils doesn't know how to export: "
              ~ @args.grep( { !$imports{$_} } ).join(', ')
        }
        $imports
    }
    else {
        Map.new
    }
}

=begin pod

=head1 NAME

List::SomeUtils - Port of Perl 5's List::SomeUtils 0.56

=head1 SYNOPSIS

    # import specific functions
    use List::SomeUtils <any uniq>;

    if any { /foo/ }, uniq @has_duplicates {
        # do stuff
    }

    # import everything
    use List::SomeUtils ':all';

=head1 DESCRIPTION

List::SomeUtils is a functional copy of L<List::MoreUtils>.  As for the
reasons of its existence, please check the documentation of the Perl 5
version.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/List-SomeUtils . Comments
and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
