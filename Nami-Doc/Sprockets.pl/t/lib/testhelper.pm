use lib './lib/';
use Sprockets::Locator;
module lib::testhelper;

my $locator = Sprockets::Locator.new(paths => {
	template => {
		directories => <t/data/themes/_shared/ t/data/themes/default/ t/data/lib/>,
		prefixes => {js => 'javascripts', css => 'stylesheets', img => 'images'}
	},
	vendor => {
		directories => ('t/data/vendor/',)
	},
});

our sub get-locator is export {
	$locator;
}
