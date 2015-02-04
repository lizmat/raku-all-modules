use Sprockets::Locator;
class Sprockets::Pipeline;

# Filters part...
# To be moved out, I guess
# I still need to decide if I want this to be per-Pipeline,
# but there doesn't seem to be a reason to
our %filters =
  'coffee' => sub { !!! },
  'pl' => &EVAL, # more like EVIL amirite
  ;

our sub apply-filters(@filters, $content) {
  $content;
}

# Locator itself
has %.paths;
has @.filters;

has Sprockets::Locator $!locator;

submethod BUILD(|) {
	callsame;

	$!locator = Sprockets::Locator.new(:%!paths);
}
