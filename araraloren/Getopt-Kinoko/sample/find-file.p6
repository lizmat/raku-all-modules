#!/usr/bin/env perl6

use Getopt::Kinoko;

my OptionSet $opts .= new();

$opts.insert-normal("h|help=b;v|version=b;");
$opts.insert-multi("w=b;");
$opts.insert-radio("d|directory=b;f|file=b;l|link=b;", :force);
$opts.push-option(
  "size-limit=i",
  callback => -> \value {
    die "Invalid integer value."
      if value !~~ Int;
  },
  comment => "the min size limit of file"
);
$opts.set-comment('help',       "print this help message");
$opts.set-comment('version',    "print the version");
$opts.set-comment('w',          "match whole file name");
$opts.set-comment('d',          "specify search file type to directory");
$opts.set-comment('f',          "specify search file type to normal file");
$opts.set-comment('l',          "specify search file type to link");
&main(getopt($opts, :gnu-style));

sub main(@noa) {
  note "Version 0.0.1"
    if $opts{'v'};

  if $opts{'h'} || $opts{'v'} {
    note "{$*PROGRAM-NAME} " ~ $opts.usage ~ "\n";
    note(.join("") ~ "\n") for $opts.comment(4);
    exit 0;
  }

  die "Not support multi keyword"
    if +@noa > 2;

  die "Need more arguments"
    if +@noa < 2;

  my ($dir, $key) = @noa;

  die "Invalid directory {$dir}"
    if $dir.IO !~~ :d;

  &search($opts, $dir, $key, -> $file { say $file.path(); });
}

sub search(OptionSet $opts, Str $dir, Str $key, &callback) {
  for $dir.IO.dir(:all) -> $file {
    my $name = $file.basename;

    next if $opts{'w'} && $name ne $key;
    next if $opts{'d'} && !$file.d;
    next if $opts{'f'} && (!$file.f || $file.s < $opts{'size-limit'}.Int);
    next if $opts{'l'} && !$file.l;

    &callback($file);
  }
}
