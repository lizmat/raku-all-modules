unit module Sprockets;
my @extensions = <js html css txt
	png gif jpg jpeg
	otf ttf>;

our sub split-filename(Str $filename) is export {
	my Str $ext;
	my @name;
  my $filters = [];

  for $filename.split('.') {
    next $ext = $_ when any(@extensions);
    # push onto name until $ext gets filled
    [$@name, $filters][defined $ext].push: $_;
  }
	fail "Missing file extension for $filename" unless $ext;

  $filters .= reverse; # last extension to be applied first
	(@name.join('.'), $ext, $filters);

  # old ...
  #do for $filename.split('.') {
  #  last $ext = $_ when any(@extensions);
  #  $_
  #}
}
