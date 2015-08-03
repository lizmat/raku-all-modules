use TAP::Entry;
use TAP::Result;

package TAP {
	grammar Grammar {
		method parse {
			my $*tap-indent = 0;
			callsame;
		}
		method subparse($, *%) {
			my $*tap-indent = 0;
			callsame;
		}
		token TOP { ^ <line>+ $ }
		token sp { <[\s] - [\n]> }
		token num { <[0..9]>+ }
		token line {
			^^ [ <plan> | <test> | <bailout> | <version> | <comment> | <yaml> | <sub-test> || <unknown> ] \n
		}
		token plan {
			'1..' <count=.num> <.sp>* [ '#' <.sp>* $<directive>=[:i 'SKIP'] <.alnum>* [ <.sp>+ $<explanation>=[\N*] ]? ]?
		}
		regex description {
			[ <-[\n\#\\]> | \\<[\\#]> ]+ <!after <sp>+>
		}
		token test {
			$<nok>=['not '?] 'ok' [ <.sp> <num> ]? ' -'?
				[ <.sp>* <description> ]?
				[ <.sp>* '#' <.sp>* $<directive>=[:i [ 'SKIP' | 'TODO'] <.alnum>* ] <.sp>+ $<explanation>=[\N*] ]?
				<.sp>*
		}
		token bailout {
			'Bail out!' [ <.sp> $<explanation>=[\N*] ]?
		}
		token version {
			:i 'TAP version ' <version=.num>
		}
		token comment {
			'#' <.sp>* $<comment>=[\N*]
		}
		token yaml {
			$<yaml-indent>=['  '] '---' \n :
			[ ^^ <.indent> $<yaml-indent> $<yaml-line>=[<!before '...'> \N* \n] ]*
			<.indent> $<yaml-indent> '...'
		}
		token sub-entry {
			<plan> | <test> | <comment> | <yaml> | <sub-test> || <!before <sp>+ > <unknown>
		}
		token indent {
			'    ' ** { $*tap-indent }
		}
		token sub-test {
			'    ' :temp $*tap-indent += 1; <sub-entry> \n
			[ <.indent> <sub-entry> \n ]*
			'    ' ** { $*tap-indent - 1 } <test>
		}
		token unknown {
			\N*
		}
	}
	class Action {
		method TOP($/) {
			make @<line>».made;
		}
		method line($/) {
			make $/.values[0].made;
		}
		method plan($/) {
			my %args = :raw(~$/), :tests(+$<count>);
			if $<directive> {
				%args<skip-all explanation> = True, $<explanation>;
			}
			make TAP::Plan.new(|%args);
		}
		method description($/) {
			make ~$/.subst(/\\('#'|'\\')/, { $_[0] }, :g)
		}
		method !make_test($/) {
			my %args = (:ok($<nok> eq ''));
			%args<number> = $<num>.defined ?? +$<num> !! Int;
			%args<description> = $<description>.made if $<description>;
			%args<directive> = $<directive> ?? TAP::Directive::{~$<directive>.substr(0,4).tclc} !! TAP::No-Directive;
			%args<explanation> = ~$<explanation> if $<explanation>;
			return %args;
		}
		method test($/) {
			make TAP::Test.new(:raw(~$/), |self!make_test($/));
		}
		method bailout($/) {
			make TAP::Bailout.new(:raw(~$/), :explanation($<explanation> ?? ~$<explanation> !! Str));
		}
		method version($/) {
			make TAP::Version.new(:raw(~$/), :version(+$<version>));
		}
		method comment($/) {
			make TAP::Comment.new(:raw(~$/), :comment(~$<comment>));
		}
		method yaml($/) {
			my $content = $<yaml-line>.join('');
			make TAP::YAML.new(:raw(~$/), :$content);
		}
		method sub-entry($/) {
			make $/.values[0].made;
		}
		method sub-test($/) {
			make TAP::Sub-Test.new(:raw(~$/), :entries(@<sub-entry>».made), |self!make_test($<test>));
		}
		method unknown($/) {
			make TAP::Unknown.new(:raw(~$/));
		}
	}

	class Parser {
		has Str $!buffer = '';
		has TAP::Entry::Handler @!handlers;
		has Grammar $!grammar = Grammar.new;
		has Action $!actions = Action.new;
		submethod BUILD(:@!handlers) { }
		method add-data(Str $data) {
			$!buffer ~= $data;
			while ($!grammar.subparse($!buffer, :$!actions)) -> $match {
				$!buffer.=substr($match.to);
				for @($match.made) -> $result {
					@!handlers».handle-entry($result);
				}
			}
		}
		method close-data() {
			if $!buffer.chars {
				warn "Unparsed data left at end of stream: $!buffer";
			}
			@!handlers».end-entries();
		}
	}
}
