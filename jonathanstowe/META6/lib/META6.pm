use v6.c;

=begin pod

=head1 NAME

META6 - Read, Parse, Generate Perl 6 META files.



=head1 SYNOPSIS

The below will generate the C<META.info> for this module.

=begin code

use META6;

my $m = META6.new(   name        => 'META6',
                     description => 'Work with Perl 6 META files',
                     version     => Version.new('0.0.1'),
                     perl        => Version.new('6'),
                     depends     => <JSON::Class>,
                     test-depends   => <Test>,
                     tags        => <devel meta utils>,
                     authors     => ['Jonathan Stowe <jns+git@gellyfish.co.uk>'],
                     auth        => 'github:jonathanstowe',
                     source-url  => 'git://github.com/jonathanstowe/META6.git',
                     support     => META6::Support.new(
                        source => 'git://github.com/jonathanstowe/META6.git'
                     ),
                     provides => {
                        META6 => 'lib/META6.pm',
                     },
                     license     => 'Artistic',
                     production  => False,

                 );

print $m.to-json;

=end code

=head1 DESCRIPTION

This provides a representation of the Perl 6 L<META
files|http://design.perl6.org/S22.html#META6.json> specification -
the META file data can be read, created , parsed and written in a manner
that is conformant with the specification.

Where they are known about it also makes allowance for "customary"
usage in existing software (such as installers and so forth.)

The intent of this is allow the generation and testing of META files for
module authors, so it can provide meta-information whether the attributes
are mandatory as per the spec and where known the places that "customary"
attributes are used, though this doesn't preclude it being used for other
purposes.

=head1 METHODS

All of the available attributes are documented in the specification so I
won't duplicate here, only documenting the methods provided by the
module.

=head2 method new

    multi method new(Str :$file!) 
    multi method new(IO::Path :$file!)
    multi method new(IO::Handle :$file!)
    multi method new(Str:D :$json!)

This is the contructor of the class, it can take a named argument C<file>
which can be the name of a file, an L<IO::Path> representing or a
L<IO::Handle> opened to a file containing the META json. Alternatively an
argument C<json> can be supplied which should contain the JSON string to
be parsed as META info.

If the file doesn't exist, cannot be opened, cannot be read or does not
contain valid JSON and exception will be thrown.

Additionally there still is the default constructor (as shown in the
L<SYNOPSIS|#SYNOPSIS>,) that allows the population of the attributes
directly (which may be useful when generating a META file.)

=head2 method to-json

    method to-json() returns Str

This is provided by L<JSON::Class>. It will return the JSON string
representation of the META info. The class should prevent there being
anything that can't be represented as JSON so it shouldn't throw an
exception.

=end pod

use JSON::Name;
use JSON::Class:ver(v0.0.5..*);

class META6:ver<0.0.5>:auth<github:jonathanstowe> does JSON::Class {

    enum Optionality <Mandatory Optional>;

    role MetaAttribute {
        has Optionality $.optionality is rw;
        has Version $.spec-version is rw = Version.new(0);
    }

    role MetaAttribute::Specfication does MetaAttribute {

    }

    role MetaAttribute::Customary does MetaAttribute {
        has Str $.where is rw;
    }

    multi sub trait_mod:<is> (Attribute $a, Optionality :$specification!) {
        set-specification($a, $specification);
    }


    multi sub trait_mod:<is> (Attribute $a, :@specification! (Optionality $optionality, Version $spec-version)) {
        set-specification($a, $optionality, $spec-version);
    }

    my sub set-specification(Attribute $a, Optionality $optionality = Optional, Version $spec-version = Version.new(0)) {
        $a does MetaAttribute::Specfication;
        $a.optionality = $optionality // Optional;
        $a.spec-version = $spec-version // Version.new(0);
        $a;
    }


    multi sub trait_mod:<is> (Attribute $a, :$customary! ) {
        $a does MetaAttribute::Customary;
        $a.optionality = Optional;
        $a.where = $customary ~~ Str ?? $customary !! 'unknown';
    }

    multi method new(Str :$file!) {
        self.new(file => $file.IO);
    }

    multi method new(IO::Path :$file!) {
        self.new(file => $file.open);
    }

    multi method new(IO::Handle :$file!) {
        my $json = $file.slurp-rest;
        self.new(:$json);
    }

    my Bool $seen-vee = False;

    multi method new(Str:D :$json!) {
        $seen-vee = False;
        self.from-json($json);
    }

    class Support {
        has Str $.source is rw is specification(Optional);
        has Str $.bugtracker is rw is specification(Optional);
        has Str $.email is rw is specification(Optional);
        has Str $.mailinglist is rw is specification(Optional);
        has Str $.irc is rw is specification(Optional);
        has Str $.phone is rw is specification(Optional);
    }

    # cope with "v0.0.1"
    sub unmarsh-version(Str() $v) returns Version {
        my $ver = Version.new($v);
        if $ver.parts[0] eq 'v' {
            $ver.parts.shift;
            warn 'prefix "v" seen in version string, this may not be what you want' unless $seen-vee;
            $seen-vee = True;
        }
        $ver;
    }


    has Version     $.meta6          is rw is marshalled-by('Str') is unmarshalled-by(&unmarsh-version) is specification(Optional) = Version.new(0);
    has Version     $.perl          is rw is marshalled-by('Str') is unmarshalled-by(&unmarsh-version) is specification(Mandatory);
    has Str         $.name          is rw is specification(Mandatory);
    has Version     $.version       is rw is marshalled-by('Str') is unmarshalled-by(&unmarsh-version) is specification(Mandatory);
    has Str         $.description   is rw is specification(Mandatory);
    has Str         @.authors       is rw is specification(Optional);
    has Str         $.author        is rw is customary;
    has Str         %.provides      is rw is specification(Mandatory);
    has Str         @.depends       is rw is specification(Optional);
    has Str         %.emulates      is rw is specification(Optional);
    has Str         %.supersedes    is rw is specification(Optional);
    has Str         %.superseded-by is rw is specification(Optional);
    has Str         %.excludes      is rw is specification(Optional);
    has Str         @.build-depends is rw is specification(Optional);
    has Str         @.test-depends  is rw is specification(Optional);
    has             %.resource      is rw is specification(Optional);
    has Support     $.support       is rw is specification(Optional);
    has Bool        $.production    is rw is specification(Optional);
    has Str         $.license       is rw is specification(Optional);
    has Str         @.tags          is rw is specification(Optional);
    has Str         $.source-url    is rw is customary;
    has Str         $.auth          is rw is customary;
}

# vim: expandtab shiftwidth=4 ft=perl6
