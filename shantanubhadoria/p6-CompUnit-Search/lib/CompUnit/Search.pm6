use v6;

=begin pod

=head1 NAME

CompUnit::Search - Search through compunits

=head1 SYNOPSIS

=head2 Search through compunits

=begin code

    use CompUnit::Search;

    my @modules = search-compunits({$_ ~~ /Test\:\:.*/});

    for @modules -> $module {
      say $module;
    }

=end code

=head1 METHODS

=head2 search-compunits

Gets a list of all installed compunits from the repositories(optional filter can be passed to show a subset of the
installed compunits). Note that at the moment this only searches in repositories of type
CompUnit::Repository::Installation, as these are the only ones which provide a quick meta to search for installed
modules. If you install anything through `panda install` it should show up in the list. Once there is a good way to
search through other repositories I will implement it here.

Returns a lazy list of Pair(s) with compunits as key and a Seq of its provides as the value.

    use CompUnit::Search;

    my @compUnits = search-compunits(* ~~ /JSON\:\:.*/); # Whatever code as a parameter to filter the compunits by name
                                                         # You may also use a block with one parameter(compunit name)
                                                         # instead for filtering purposes.

    for @compUnits -> $compUnit {
      say $compUnit;
    }

Output:

    JSON::Unmarshal => (JSON::Unmarshal)
    JSON::Marshal => (JSON::Marshal)
    JSON::Tiny => (JSON::Tiny JSON::Tiny::Actions JSON::Tiny::Grammar)
    JSON::Pretty => (JSON::Pretty)
    JSON::Class => (JSON::Class)
    JSON::Infer => (JSON::Infer)
    JSON::RPC => (JSON::RPC::Server X::JSON::RPC JSON::RPC::Client)
    JSON::Name => (JSON::Name)
    JSON::Fast => (JSON::Fast)

=head2 search-provides

Gets a list of provides and the compunits that provide them. This function filters based on the provides' name. Provide
can be a package, class, role, module, grammar etc. as specified in the Meta file for the compunit. Returns a lazy list
of Pair(s) with a provide as the key and the compunit that provides that provide as the value.

    use CompUnit::Search;

    my @compUnits = search-provides(* ~~ /JSON\:\:.*/);

    for @compUnits -> $compUnit {
      say $compUnit;
    }

Output:

    JSON::Unmarshal => JSON::Unmarshal
    JSON::Marshal => JSON::Marshal
    JSON::Tiny => JSON::Tiny
    JSON::Tiny::Actions => JSON::Tiny
    JSON::Tiny::Grammar => JSON::Tiny
    JSON::Pretty => JSON::Pretty
    JSON::Class => JSON::Class
    JSON::Infer => JSON::Infer
    JSON::RPC::Server => JSON::RPC
    X::JSON::RPC => JSON::RPC
    JSON::RPC::Client => JSON::RPC
    JSON::Name => JSON::Name
    JSON::Fast => JSON::Fast

=head1 REFERENCE

Compilation Units http://design.perl6.org/S11.html

=head1 SUPPORT

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through github at
L<https://github.com/shantanubhadoria/p6-CompUnit-Search/issues>.
You will be notified automatically of any progress on your issue.

=head2 Source Code

This is open source software.  The code repository is available for
public review and contribution under the terms of the license.

L<https://github.com/shantanubhadoria/p6-CompUnit-Search>

  git clone git://github.com/shantanubhadoria/p6-CompUnit-Search.git

=head1 AUTHOR

Shantanu Bhadoria <shantanu@cpan.org> L<https://www.shantanubhadoria.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Shantanu Bhadoria.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 6 programming language system itself.

=end pod

unit module CompUnit::Search:ver<2.0.0>:auth<github:shantanubhadoria>;

sub search-compunits($callback = {True}) is export {
  my $repo = $*REPO;
  lazy gather repeat {
    given $repo.^name {
      when 'CompUnit::Repository::Installation' {
        for $repo.installed -> $distribution {
          if $distribution.meta && $callback($distribution.meta<name>) {
            take $distribution.meta<name> => $distribution.meta<provides>.keys;
          }
        }
      }
    }
  } while $repo = $repo.next-repo;
}

sub search-provides($callback = {True}) is export {
  my $repo = $*REPO;
  lazy gather repeat {
    given $repo.^name {
      when 'CompUnit::Repository::Installation' {
        for $repo.installed -> $distribution {
          for $distribution.meta<provides>.keys -> $provides {
            if $callback($provides) {
              take $provides => $distribution.meta<name>;
            }
          }
        }
      }
    }
  } while $repo = $repo.next-repo;
}
