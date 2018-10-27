use Sprockets::Locator;
unit class Sprockets::Pipeline;

# Locator itself
has %.paths;
has @.filters;

has Sprockets::Locator $!locator;

submethod BUILD(|) {
	callsame;

	$!locator = Sprockets::Locator.new(:%!paths);
}
