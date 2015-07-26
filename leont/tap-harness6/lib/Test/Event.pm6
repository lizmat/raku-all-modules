use TAP::Entry;

package Test {
	role Event {
	}

	class Event::Plan does Event {
		has Int:D $.tests;
		has Bool $.skip-all;
		has Str $.explanation;
	}

	class Event::Test {
		has Bool $.ok;
		has TAP::Test::Description $.description;
		has TAP::Directive $.directive = TAP::No-Directive;
		has TAP::Directive::Explanation $.explanation;
	}

	class Event::Comment does Event {
		has Str:D $.content;
	}

}
