use TAP;

package Test {
	role Event {
	}

	class Event::Plan does Event {
		has Int:D $.tests is required;
		has Bool $.skip-all;
		has Str $.explanation;
	}

	class Event::Test {
		has Bool:D $.ok is required;
		has TAP::Test::Description $.description;
		has TAP::Directive $.directive = TAP::No-Directive;
		has TAP::Directive::Explanation $.explanation;
	}

	class Event::Comment does Event {
		has Str:D $.content is required;
	}

}
