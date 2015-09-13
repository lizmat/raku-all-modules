use v6;

unit class Pekyll;

=begin pod

=head1 NAME

Pekyll - simple static website generator

=head1 SYNOPSIS

    use Pekyll;
    use Pekyll::Routers;
    use Pekyll::Compilers;
    
    my %rules = (
        'assets/*' => { router=>&router_id, compiler=>&plain_copy },
        'static/*' => { router=>&ext2html,  compiler=>&compile_static },
        '_end'     => &wrap_up,
      );
    
    my $pekyll = Pekyll.new(:%rules);
    $pekyll.build('src', 'dist');
    
    sub compile_static($src, $target) { ...  }
    sub wrap_up($dst) { ... }


=head1 AUTHOR

Nuno Carvalho

=end pod

has $.rules is rw;

method build($src = 'src', $dst = 'dist') {
  say "Building site to <$dst>, source is <$src> ...";

  $dst.IO ~~ :d or mkdir $dst;

  $.rules<_begin> and $.rules<_begin>();

  my @files = my-find($src);
  for @files -> $file {
    $.process($file, $src, $dst);
  }

  $.rules<_end> and $.rules<_end>($dst);
}

method process($file, $src, $dst) {
  say "Processing: $file";
  for ($.rules.keys) {
    $_ ~~ m/^_/ and next;
    if ( match($file, $_) ) {
     my $target = $dst ~ $.rules{$_}<router>($file.subst(/^$src/, ''));
     validate($target);
     $.rules{$_}<compiler>($file, $target);
     last;
    }
  }
}

sub my-find($dir) {
  my @files;

  my @todo = $dir.IO;
  while @todo {
    for @todo.pop.dir -> $path {
      @files.push($path.Str) unless $path.Str.IO ~~ :d;
      @todo.push: $path if $path.d;
    }
  }

  return @files;
}

sub match($file, $expr) {
  my $basename = IO::Path.new($file).basename;
  my $match = False;

  # FIXME better way to match, need re interpolation
  my ($left, $right) = $expr.split('*');
  $match = True if $file ~~ /$left .*? $right/;

  return $match;
}

sub validate($target) {
  my $dirname = IO::Path.new($target).dirname;

  $dirname.IO ~~ :d or mkdir $dirname;
}

