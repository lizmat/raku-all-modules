use v6.c;

class X::JSON::Pointer::InvalidSyntax is Exception {
    has $.pos;
    has $.pointer;

    method message() {
        "Invalid syntax at {$!pos} when trying to resolve 「{$!pointer}」"
    }
}

class X::JSON::Pointer::NonExistent is Exception {
    has $.element;

    method message() {
        "Element does not exist at $!element"
    }
}

grammar JSONPointer {
    token TOP { ['/' <reference-token> || <.panic()>]*? $ }
    token reference-token { (<unescaped> || <escaped>)+ }
    token unescaped { <[\x00 .. \x2E \x30 .. \x7D \x7F .. \x10FFFF]> }
    token escaped   { '~' <[01]> }

    method panic() {
        die X::JSON::Pointer::InvalidSyntax.new(pos => self.CURSOR.pos,
                                                pointer => self.CURSOR.orig);
    }
}

class JSON::Pointer {
    has @.parts;

    method !escape($token) {
        my $res = $token.subst('~1', '/', :g);
        $res.subst('~0', '~', :g);
    }
    method !unescape($token) {
        my $res = $token.subst('~', '~0', :g);
        $res.subst('/', '~1', :g);
    }

    multi method new(*@parts) {
        self.bless(parts => @parts.map({self!escape($_)}));
    }
    multi method new(:@parts) {
        self.bless(:@parts);
    }

    method parse(Str $pointer --> JSON::Pointer) {
        my @parts;
        my $result = JSONPointer.parse($pointer);
        for $result<reference-token> {
            my $token = self!escape(~$_[0].join);
            $token = $token.Int if $token ~~ /^ ('0' || <[1..9]>\d*) $/;
            @parts.push: $token;
        }
        self.new(:@parts);
    }

    method tokens() { @!parts }

    multi method resolve($json) {
        return $json if @!parts.elems == 0;
        my $res = $json;
        for @!parts {
            $res = self.resolve($res, $_);
        }
        $res;
    }

    multi method resolve(Associative $json, $part) {
        return fail X::JSON::Pointer::NonExistent.new(:element($part)) if $part !~~ Str;
        $json{$part} // fail X::JSON::Pointer::NonExistent.new(:element($part));
    }
    multi method resolve(Positional $json, $part) {
        return fail X::JSON::Pointer::NonExistent.new(:element($part)) if $part eq '~';
        return fail X::JSON::Pointer::NonExistent.new(:element($part)) if $part !~~ Int;
        $json[$part] // fail X::JSON::Pointer::NonExistent.new(:element($part));
    }
    multi method resolve(Failure $f, $_) { $f }

    method Str() {
        '/' ~ @!parts.map({self!unescape($_)}).join('/');
    }
}

=begin pod

=head1 NAME

JSON::Pointer - JSON Pointer implementation in Perl 6.

=head1 SYNOPSIS

  use JSON::Pointer;

  # An example document to resolve pointers in
  my $sample-json = {
      foo => [
          {
              bar => 42
          },
          {
              'weird~odd/name' => 101
          }
      ]
  }

  # Simple usage
  my $p = JSON::Pointer.parse('/foo/0/bar');
  say $p.tokens; # [foo 0 bar]
  say $p.resolve($sample-json); # 42

  # ~ and / are escaped as ~0 and ~1
  my $p2 = JSON::Pointer.parse('/foo/1/weird~0odd~1name');
  say $p2.tokens; # [foo 1 weird~odd/name]
  say $p2.resolve($sample-json); # 101

  # A Failure is returned upon resolution failure
  my $p3 = JSON::Pointer.parse('/foo/2/missing');
  without $p3.resolve($sample-json) {
      say "Could not resolve";
  }

  # Construct a JSON pointer
  my $p4 = JSON::Poiner.new('foo', 0, 'weird~odd/name');
  say ~$p4; # /foo/0/weird~0odd~1name

=head1 DESCRIPTION

JSON::Pointer is a Perl 6 module that implements JSON Pointer conception.

=head1 AUTHOR

Alexander Kiryuhin <alexander.kiryuhin@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Edument Central Europe sro.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
