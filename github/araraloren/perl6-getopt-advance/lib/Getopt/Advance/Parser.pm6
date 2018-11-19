
use Getopt::Advance::Utils;
use Getopt::Advance::Context;
use Getopt::Advance::Option;
use Getopt::Advance::Exception;
use Getopt::Advance::Argument;

unit module Getopt::Advance::Parser;

my constant ParserRT = sub { True };
my constant ParserRF = sub { False };
my Int $messageid = 0;

role Parser { ... }
role TypeOverload { ... }
role ResultHandler { ... }
role ResultHandlerOverload { ... }

class ReturnValue is export {
    has $.optionset;
    has $.noa;
    has $.parser;
    has %.return-value;
}

grammar OptionGrammar is export {
	token TOP { ^ <option> $ }

	proto token option {*}

	token option:sym<s> { '-'  <optname> }

	token option:sym<l> { '--' <optname> }

	token option:sym<ds>{ '-/' <optname> }

	token option:sym<dl>{ '--/'<optname> }

	token option:sym<sv>{ '-'  <optname> '=' <optvalue> }

	token option:sym<lv>{ '--' <optname> '=' <optvalue>	}

	token optname {
        <-[\=\-]> <-[\=]>*
	}

	token optvalue {
		.+
	}
}

class OptionActions is export {
	has $.name;
	has $.value;
	has $.prefix;
    has $.handler;
    has $.typeoverload;
    has $.publisher;

    method publish(|c) {
        $!publisher.publish(|c);
    }

    method set-typeoverload($typeoverload) {
        $!typeoverload = $typeoverload;
    }

    method set-handler(ResultHandler $handler) {
        $!handler = $handler;
    }

    method set-publisher(Publisher $publisher) {
        $!publisher = $publisher;
    }

	method option:sym<s>($/) {
		$!name = ~$<optname>;
		$!prefix = Prefix::SHORT;
	}

	method option:sym<l>($/) {
		$!name = ~$<optname>;
		$!prefix = Prefix::LONG;
	}

	method option:sym<ds>($/) {
		$!name  = ~$<optname>;
		$!value = False;
		$!prefix = Prefix::SHORT;
	}

	method option:sym<dl>($/) {
		$!name  = ~$<optname>;
		$!value = False;
		$!prefix = Prefix::LONG;
	}

	method option:sym<lv>($/) {
		$!name  = ~$<optname>;
		$!value = ~$<optvalue>;
		$!prefix = Prefix::LONG;
	}

	method option:sym<sv>($/) {
		$!name  = ~$<optname>;
		$!value = ~$<optvalue>;
		$!prefix = Prefix::SHORT;
	}

    method !guess-option(&getarg) {
        my @guess;

        if $!value.defined {
            @guess.push([ $!value === False ?? False !! True, sub { $!value }, False ]);
        } elsif &getarg.defined {
            @guess.push([ True,  &getarg, True]);
            @guess.push([ False, ParserRT, False]);
        } else {
            @guess.push([ False, ParserRT, False]);
        }
        @guess;
    }

    multi method islike(:$long!) {
        $!prefix == Prefix::LONG;
    }

    multi method islike(:$xopt!) {
        $!prefix == Prefix::SHORT && $!name.chars > 1;
    }

    multi method islike(:$short!) {
        $!prefix == Prefix::SHORT && $!name.chars == 1;
    }

    multi method islike(:$ziparg!) {
        $!name.chars > 1 && !$!value.defined;
    }

    multi method islike(:$comb!) {
        $!name.chars > 1;
    }

    method type() {
        $!typeoverload;
    }

    # generate option like '--foo', aka long style
    multi method broadcast-option(&getarg, :$long!) {
        # skip option like '-f'
        if self.islike(:long)  {
            for self!guess-option(&getarg) -> $g {
                self.publish: self.type.contextprocessor.new(
                    id => $messageid++,
                    handler => $!handler,
                    style => Style::LONG,
                    contexts => [
                        self.type.optcontext.new(
                            prefix => $!prefix,
                            name   => $!name,
                            hasarg => $g.[0],
                            getarg => $g.[1],
                            canskip=> $g.[2],
                        )
                    ],
                );
            }
        }
    }

    # generate option like '-foo', but not '-f', aka x-style
    multi method broadcast-option(&getarg, :$xopt!) {
        # skip option like '-f'
        if self.islike(:xopt) {
            for self!guess-option(&getarg) -> $g {
                self.publish: self.type.contextprocessor.new(
                    id => $messageid++,
                    handler => $!handler,
                    style => Style::XOPT,
                    contexts => [
                        self.type.optcontext.new(
                            prefix => $!prefix,
                            name   => $!name,
                            hasarg => $g.[0],
                            getarg => $g.[1],
                            canskip=> $g.[2],
                        )
                    ]
                );
            }
        }
    }

    # generate option like '-a', aka short style
    multi method broadcast-option(&getarg, :$short!) {
        if self.islike(:short) {
            for self!guess-option(&getarg) -> $g {
                self.publish: self.type.contextprocessor.new(
                    id => $messageid++,
                    handler => $!handler,
                    style => Style::SHORT,
                    contexts => [
                        self.type.optcontext.new(
                            prefix => $!prefix,
                            name   => $!name,
                            hasarg => $g.[0],
                            getarg => $g.[1],
                            canskip=> $g.[2],
                        )
                    ]
                );
            }
        }
    }

    # generate option like '[-|--]ab' ==> '[-|--]a b, that mean b is argument of option a
    multi method broadcast-option(&getarg, :$ziparg!) {
        if self.islike(:ziparg) {
            self.publish: self.type.contextprocessor.new(
                id => $messageid++,
                handler => $!handler,
                style => Style::ZIPARG,
                contexts => [
                    self.type.optcontext.new(
                        prefix => $!prefix,
                        name   => $!name.substr(0, 1),
                        hasarg => True,
                        getarg => sub { $!name.substr(1); },
                        canskip=> False,
                    )
                ]
            );
        }
    }

    # generate option like '[-|--][/]ab' ==> '[-|--][/]a [-|--][/]b, that mean multi option
    multi method broadcast-option(&getarg, :$comb!) {
        if self.islike(:comb) {
            my @opts = $!name.comb;
            my @contexts;

            for @opts[0..*-2] -> $opt {
                @contexts.push(
                    self.type.optcontext.new(
                            prefix => $!prefix,
                            name   => $opt,
                            hasarg => False,
                            getarg => do {
                                ($!value === False) ?? (ParserRF) !! (ParserRT);
                            },
                            canskip=> False,
                        )
                );
            }
            for self!guess-option(&getarg) -> $g {
                my @t = @contexts;
                @t.push(
                    self.type.optcontext.new(
                        prefix => $!prefix,
                        name   => @opts[*-1],
                        hasarg => $g.[0],
                        getarg => $g.[1],
                        canskip=> $g.[2],
                    )
                );
                self.publish: self.type.contextprocessor.new(
                    id => $messageid++,
                    handler => $!handler,
                    style => Style::COMB,
                    contexts => @t
                );
            }
        }
    }
}

role ResultHandler is export {
    has $.success = False;
    has $.skiparg = False;

    #| set we match success
    method set-success() { $!success = True; self; }

    #| reset the status, so we can use the handler next time
    method reset() {
        $!success = $!skiparg = False;
        self;
    }

    #| will called after the ContextProcessor process the thing
    method handle($parser) { self; }

    #| when option want skip the argument, call this method, default do nothing
    method skip-next-arg() { self; }
}

role TypeOverload is export {
    has $.optgrammar is rw;
    has $.optactions is rw;
    has $.optcontext is rw;
    has $.poscontext is rw;
    has $.cmdcontext is rw;
    has $.maincontext is rw;
    has $.contextprocessor is rw;
}

role ResultHandlerOverload is export {
    has $.prh is rw; #| for pos
    has $.crh is rw; #| for cmd
    has $.mrh is rw; #| for main
    has $.brh is rw; #| for bsd-style option
    has $.orh is rw; #| for option
}

my class OptionResultHandler does ResultHandler {
    method skip-next-arg() {
        $!skiparg = True;
        self;
    }
    method handle($parser) {
        Debug::debug("Call handler for option [{$parser.arg}]");
        unless self.success {
            &ga-parse-error("Can not find the option: {$parser.arg}");
        }
        #| skip next argument if the option has consume an argument
        $parser.skip() if self.skiparg();
        self;
    }
}

role Parser does Getopt::Advance::Utils::Publisher does RefOptionSet is export {
    has Bool $.strict;
    has Bool $.autohv;
    has Bool $.bsd-style;
    has Int  $.index;
    has Int  $.count;
    has Int  $!noaIndex;
    has $.arg;
    has @.noa;
    has &.is-next-arg-available;
    has &.optcheck;
    has &.cmdcheck;
    has @.styles;
    has @.args;
    has $.typeoverload = TypeOverload.new(
        optgrammar => OptionGrammar,
        optactions => OptionActions,
        optcontext => TheContext::Option,
        poscontext => TheContext::Pos,
        cmdcontext => TheContext::NonOption,
        maincontext=> TheContext::NonOption,
        contextprocessor => Getopt::Advance::Utils::ContextProcessor, #| seems like a bug, need module package
    );
    has $.handler = ResultHandlerOverload.new;

    method init(@!args,  :@order) {
        $!noaIndex = $!index = 0;
        $!count = +@!args;
        @!noa = [];
        unless &!is-next-arg-available.defined {
            &!is-next-arg-available = sub ( Parser $parser --> False ) {
                given $parser {
                    if (.index + 1 < .count) {
                        given .args[.index + 1] {
                            unless $parser.strict && (
                                .starts-with('-')  || .starts-with('--') || .starts-with('-/') || .starts-with('--/')
                            ) {
                                return True;
                            }
                        }
                    }
                }
            }
        }
        unless $!handler.orh.defined {
            $!handler.orh = OptionResultHandler.new;
        }
        unless $!handler.prh.defined {
            $!handler.prh = ResultHandler.new;
        }
        unless $!handler.crh.defined {
            $!handler.crh = ResultHandler.new;
        }
        if $!bsd-style {
            unless $!handler.brh.defined {
                $!handler.brh = ResultHandler.new;
            }
        }
		unless $!handler.mrh.defined {
			$!handler.mrh = class :: does ResultHandler {
				method set-success() { } # skip the set-success, we need call all the MAINs
			}.new;
		}
        unless &!cmdcheck.defined {
            &!cmdcheck = sub (\self) {
                self.owner.check-cmd(+@!noa);
            };
        }
        unless &!optcheck.defined {
            &!optcheck = sub (\self) {
                self.owner.check();
            };
        }
        if +@order > 0 {
            my (%order, @sorted);
            %order{ @order } = 0 ...^ +@order;
            for @!styles -> $style {
                @sorted[%order{$style.key.Str}] = $style;
            }
            @!styles = @sorted;
        } elsif +@order == 0 && +@!styles == 0 {
            &ga-raise-error('Set the :@order, styles for parser!');
        }
        Debug::debug("Style: {@!styles>>.key.join(" > ")}");
        self.clean-subscriber();
        self;
    }

    #| skip current argument
    method skip() {
        $!index += 1;
    }

    method ignore() {
        @!noa.push(
            my $a = Argument.new(
                index => $!noaIndex++,
                value => $!arg,
            )
        );
        $a;
    }

    method type() {
        $!typeoverload;
    }

    method handler() {
        $!handler;
    }

    method CALL-ME() {
        while $!index < $!count {
            ($!arg, my $actions) = ( @!args[$!index], self.type.optactions.new );

            sub get-option-arg() { @!args[$!index + 1]; }

            Debug::debug("Process the argument '{$!arg}'\@{$!index}");

            if self.type.optgrammar.parse($!arg, :$actions) {
                #| the action need handler pass it to ContextProcessor
                $actions.set-typeoverload(self.type);
                $actions.set-handler(self.handler.orh.reset());
                $actions.set-publisher(self);
                for @!styles -> $style {
                    if $style.defined {
                        Debug::debug("** Start broadcast {$style.key.Str} style option");
                        $actions.broadcast-option(&!is-next-arg-available(self) ?? &get-option-arg !! Callable, |$style);
                        Debug::debug("** End");
                    }
                }
                $!handler.orh.handle(self);
            } else {
                my $bsdmc;

                #| if we need suppot bsd style
                if $!bsd-style {
                    #| reset the bsd style handler
                    $bsdmc = self.type.contextprocessor.new( handler => self.handler.brh.reset(),
                        style => Style::BSD,
                        id => $messageid++,
                        contexts => [
                            self.type.optcontext.new(
                                prefix  => Prefix::NULL,
                                name    => $_,
                                hasarg  => False,
                                getarg  => ParserRT,
                                canskip => False,
                            ) for $!arg.comb();
                        ]
                    );
                    Debug::debug("** Broadcast a bsd style option [{$!arg.comb.join("|")}]");
                    self.publish: $bsdmc;
                    self.handler.brh.handle(self);
                    Debug::debug("** End");
                }

                #| if not bsd style or it matched failed
                if !$!bsd-style || !$bsdmc.matched {
                    self.ignore();
                }
            }
            #| increment the index
            self.skip();
        }

        Debug::debug(" + Check the option and group");
        &!optcheck(self);

        #| last, we should emit the CMD and MAIN
        if +@!noa > 0 {
            Debug::debug("** Broadcast the CMD NonOption");
            self.publish: self.type.contextprocessor.new( handler => self.handler.crh.reset(),
                style => Style::CMD,
                id => $messageid++,
                contexts => [
                    self.type.cmdcontext.new( argument => @!noa, index => 0),
                ]
            );
            self.handler.crh.handle(self);
            Debug::debug("** End");
            Debug::debug("** Begin POS and WHATEVERPOS NonOption");
            for @!noa -> $noa {
                self.publish: self.type.contextprocessor.new( handler => self.handler.prh.reset(),
                    style => Style::WHATEVERPOS,
                    id => $messageid++,
                    contexts => [
                        self.type.poscontext.new( argument => @!noa, index => $noa.index ),
                    ]
                );
                self.handler.prh.handle(self);
                #| maybe a POS
                self.publish: self.type.contextprocessor.new( handler => self.handler.prh.reset(),
                    style => Style::POS,
                    id => $messageid++,
                    contexts => [
                        self.type.poscontext.new( argument => @!noa, index => $noa.index ),
                    ]
                );
                self.handler.prh.handle(self);
            }
            Debug::debug("** End");
        }
        #| check the cmd and pos@0
        Debug::debug(" + Check the cmd and pos@0");
        &!cmdcheck(self);

        #| check if autohv is true
        my $needhelp = $!autohv && &check-if-need-autohv(self.owner());

        Debug::debug("** {$needhelp ?? "Skip b" !! "B"}roadcast the MAIN NonOption");

        if ! $needhelp {
            #| we don't want skip any other MAINs, so we using $!mrh skip the set-success method
            self.publish: self.type.contextprocessor.new( handler => self.handler.mrh.reset(),
                style => Style::MAIN,
                id => $messageid++,
                contexts => [
                    self.type.maincontext.new( argument => @!noa, index => -1 ),
                ]
            );
            self.handler.mrh.handle(self);
        }
        self;
    }
}

class PreParser does Parser is export {
    has @.prenoa;

    method init(|c) {
        @!prenoa = [];
        self.Parser::init(|c);
    }

    method preignore() {
        @!prenoa.push($!arg);
    }

    method ignore() {
        self.preignore();
        self.Parser::ignore();
    }

    submethod TWEAK() {
        $!handler.orh = class :: does ResultHandler {
            method skip-next-arg() {
                $!skiparg = True;
                self;
            }
            method handle($parser) {
                Debug::debug("Pre Parser call handler for option [{$parser.arg}]");
                #| skip next argument if the option has consume an argument
                if self.success {
                    $parser.skip() if self.skiparg();
                } else {
                    Debug::debug("Ignore current option: {$parser.arg} !");
                    $parser.ignore();
                }
                self;
            }
        }.new;
    }
}

sub ga-parser($parserobj, @args, $optset, *%args) is export {
    Debug::debug("Call ga-parser, got arguments '{@args.join(",")}' from input");
    $parserobj.init(@args);
    $parserobj.set-owner($optset);
    $optset.set-parser($parserobj);
    $parserobj.();
    ReturnValue.new(
        optionset   => $optset,
        noa         => $parserobj.noa,
        parser      => $parserobj,
        return-value=> do {
            my %rvs;
            for %($optset.get-main()) {
                %rvs{.key} = .value.value;
            }
            %rvs;
        }
    );
}

sub ga-pre-parser($parserobj, @args, $optset, *%args) is export {
    Debug::debug("Call ga-pre-parser, got arguments '{@args.join(",")}' from input");
    $parserobj.init(@args);
    $parserobj.set-owner($optset);
    $optset.set-parser($parserobj);
    $parserobj.();
    ReturnValue.new(
        optionset   => $optset,
        noa         => $parserobj.prenoa,
        parser      => $parserobj,
        return-value=> do {
            my %rvs;
            for %($optset.get-main()) {
                %rvs{.key} = .value.value;
            }
            %rvs;
        }
    );
}

class SaveOVSHandler is OptionResultHandler {
    has @.ovs;

    method saveOVS($r) {
        @!ovs.push($r);
    }

    method setOVS() {
        .set-value() for @!ovs;
    }
}

class SaveContextProcessor is Getopt::Advance::Utils::ContextProcessor {
    method process($o) {
        Debug::debug("== message {self.id}: [{self.style}|{self.contexts>>.gist.join(" + ")}]");
        if self.matched() {
            Debug::debug("- Skip");
        } else {
            Debug::debug("- Match <-> {$o.usage}");
            my ($matched, $skip) = (True, False);
            for self.contexts -> $context {
                if ! $context.success {
                    if $context.match(self, $o) {
                        if (my $r = $context.set(self, $o)) ~~ OptionValueSetter {
                            self.handler.saveOVS($r);
                            $skip ||= $context.canskip;
                        }
                    } else {
                        $matched = False;
                    }
                }
            }
            if $matched {
                if $skip {
                    Debug::debug("  - Call handler to shift argument.");
                    self.handler.skip-next-arg();
                }
                self.handler.set-success();
            }
        }
        Debug::debug("- process end {self.id}");
    }
}

class Parser2 does Parser is export {
    submethod TWEAK() {
        self.type.contextprocessor = SaveContextProcessor;
        self.type.optcontext = TheContext::DelayOption;
        self.handler.orh = SaveOVSHandler.new;
        &!cmdcheck = sub (\self) {
            self.handler.orh.setOVS();
            self.owner.check();
            self.owner.check-cmd(self.noa.elems);
        };
        &!optcheck = sub (\self) { };
    }
}

sub ga-parser2($parserobj, @args, $optset, *%args) is export {
    Debug::debug("Call ga-parser2, got arguments '{@args.join(",")}' from input");
    $parserobj.init(@args);
    $parserobj.set-owner($optset);
    $optset.set-parser($parserobj);
    $parserobj.();
    ReturnValue.new(
        optionset   => $optset,
        noa         => $parserobj.noa,
        parser      => $parserobj,
        return-value=> do {
            my %rvs;
            for %($optset.get-main()) {
                %rvs{.key} = .value.value;
            }
            %rvs;
        }
    );
}
