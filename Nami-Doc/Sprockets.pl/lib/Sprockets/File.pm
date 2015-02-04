class Sprockets::File;
use Sprockets::Filter;

has Str $.realpath; # file's realpath
has @.filters; # filters to apply

has Str $!content; # lazy field (@see Str)

method Str {
  $!content //= (
	  self!fetch-content
    ==> apply-filters(@.filters)
  )
}

method !fetch-content is cached {
	slurp $.realpath;
}
