use v6;
unit class IO::TailFile;

# XXX rakudo caches the existence of a file...
# https://github.com/rakudo/rakudo/blob/nom/src/core/IO/Path.pm#L9
my class File {
    use nqp;
    has $.file;
    method new($file) { self.bless(:$file) }
    method e { nqp::stat($!file, nqp::const::STAT_EXISTS) == 1 }
    method s { nqp::stat($!file, nqp::const::STAT_FILESIZE) }
    method inode { nqp::stat($!file, nqp::const::STAT_PLATFORM_INODE) }
    method IO { $!file.IO }
    method open(|c) { self.IO.open(|c) }
    method dirname { self.IO.dirname }
    method watch { self.IO.watch }
    method Str { $!file }
}

my class Impl {
    has File $.file is required;
    has IO::Path $.dir = $!file.dirname.IO;
    has $.size = 0;
    has $.io;
    has $.chomp;
    has $.inode = -1;

    method reset() {
        $!size  = 0;
        $!io.close if $!io;
        $!io = Nil;
    }
    method Supply() {
        my $supply = supply {
            whenever $!dir.watch -> $event {
                self!process if $event.path eq $!file;
            };
        };
        $supply.lines(:$!chomp);
    }
    method !process() {
        return unless $!file.e;
        my $current-inode = $!file.inode;
        if $!inode != $current-inode {
            self.reset;
            $!inode = $current-inode;
        }
        my $current-size = $!file.s;
        return if $!size == $current-size;
        $!io //= try $!file.open(:r);
        return unless $!io;
        my $buf = $!io.read(2048);
        $!size += $buf.elems;
        emit($buf.decode);
    }
}

method new(|) { die "call watch() method instead" }

method watch(::?CLASS:U: $filename, Bool :$chomp = False) {
    my $file = File.new($filename.IO.abspath);
    Impl.new(:$file, :$chomp).Supply;
}

=begin pod

=head1 NAME

IO::TailFile - emulation of tail -f

=head1 SYNOPSIS

  use IO::TailFile;

  # (a) reactive way
  react {
    whenever IO::TailFile.watch("access.log", :chomp) -> $line {
      say $line;
    };
  };

  # (b) use lazy list
  my @line = IO::TailFile.watch("access.log", :chomp).list.lazy;
  for @line -> $line {
    say $line;
  };

=head1 DESCRIPTION

IO::TailFile is a emulation of C<tail -f>.

=head1 AUTHOR

Shoichi Kaji <skaji@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
