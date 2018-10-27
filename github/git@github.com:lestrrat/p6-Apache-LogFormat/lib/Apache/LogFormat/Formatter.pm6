use v6;

unit class Apache::LogFormat::Formatter;

has &!callback;

method new(&callback) {
    return self.bless(:&callback);
}

submethod BUILD(:&!callback) { }

# %env is the PSGI environment hash
# @res is a 3 item list, in PSGI style
method format(Apache::LogFormat::Formatter:D: %env, @res, $length, $reqtime, $time) {
    return &!callback(%env, @res, $length, $reqtime, $time) ~ "\n";
}


=begin pod

=head1 NAME

Apache::LogFormat::Formatter - Creates Log Lines

=head1 SYNOPSIS

  use Apache::LogFormat::Formatter;
  my $fmt = Apache::LogFormat::Formatter.new(sub(%env, @res, $length, $reqtime, $time) {
    ...
  });
  my $line = $fmt.format(%env, @res, $length, $reqtime, $time);
  $*ERR.print($line);

=head1 DESCRIPTION

Apache::LogFormat::Formatter creates strings out of bunch of data. You usually
do not have to create one yourself, as it will be created by Apache::LogFormat::Compiler.

=head1 AUTHOR

Daisuke Maki <lestrrat@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Daisuke Maki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

