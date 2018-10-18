use v6.c;
unit class CompUnit::Repository::Mask does CompUnit::Repository;

has SetHash $!mask;

submethod BUILD(:$mask) {
    $!mask = $mask.SetHash;
}

method id() {
    "mask"
}

method need($spec) {
    if $spec.from eq "Perl6" and $!mask{$spec.short-name}:exists or not self.next-repo {
        X::CompUnit::UnsatisfiedDependency.new(:specification($spec)).throw
    }

    self.next-repo.need($spec)
}

method mask($module) {
    $!mask{$module} = True;
}

method unmask($module) {
    $!mask{$module}:delete;
}

method loaded() {
    Nil
}

my CompUnit::Repository::Mask $masker;
sub mask-module($module) is export(:mask-module) {
    unless $masker {
        CompUnit::RepositoryRegistry.use-repository(
            $masker = CompUnit::Repository::Mask.new
        );
    }
    $masker.mask($module);
}
sub unmask-module($module) is export(:unmask-module) {
    unless $masker {
        die "We haven't masked anything yet?";
    }
    $masker.unmask($module);
}

=begin pod

=head1 NAME

CompUnit::Repository::Mask - hide installed modules for testing.

=head1 SYNOPSIS

  use CompUnit::Repository::Mask :mask-module, :unmask-module;
  mask-module('Test');
  try require Test; # now fails
  unmask-module('Test');
  require Test; # succeeds

=head1 DESCRIPTION

CompUnit::Repository::Mask helps testing code dealing with optional
dependencies. It allows for masking and unmasking installed modules, so
you can write tests for when the dependency is missing and for when it's
installed.

=head1 AUTHOR

Stefan Seifert <nine@detonation.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Stefan Seifert

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
