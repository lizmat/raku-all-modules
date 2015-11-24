=NAME X::Protocol - Perl6 Exception superclass for protocol result codes

=begin SYNOPSIS
=begin code


    # A simple example for a protocol that just has error codes
    class X::Protocol::SneakerNet is X::Protocol {
        method protocol { "SneakerNet" }
    }
    my @errors = X::Protocol::SneakerNet.new(:status(10)),
                 X::Protocol::SneakerNet.new(:status("11")),
                 X::Protocol::SneakerNet.new(:status("12.5")),
                 X::Protocol::SneakerNet.new(:status("13W")),
                 X::Protocol::SneakerNet.new(:status("XL")),
                 X::Protocol::SneakerNet.new(:status("XXL"));

    # A default .Numeric and .Str are provided based on :status,
    # so you can handle the above errors like this:
    for @errors {
        when 10     { say "Matches the first one" }
        when 11     { say "Matches the second one" }
        when 12.5   { say "Matches the third one" }
        when "13W"  { say "Matches the fourth one" }
        when /XL/   { say "Matches the fifth and sixth one" }
    }
    #-> Matches the first one
    #-> Matches the second one
    #-> Matches the third one
    #-> Matches the fourth one
    #-> Matches the fifth and sixth one
    #-> Matches the fifth and sixth one

    # This shows several of the more useful tweaks available:
    # 1) human-readable strings via a "codes" method
    # 2) custom "severity" levels and mapping from status to severity.
    # 3) custom "toss" method to perform actions like throw or fail.

    class X::Protocol::IPoUSPO is X::Protocol {
        method protocol { "IPoUSPO" }
	method codes {
            {
                500 => "Chased away by dog",
                400 => "A snowy, rainy, hot and gloomy night",
                200 => "Delivered"
            }
	}
	method severity { ~$.status ~~ /\d/ // "unknown" }
	method toss {
	    if self.severity > 4 { self.fail }
	    elsif self.severity > 2 { self.throw }
	    else { note self.gist }
	}
    }

    # The default message shows protocol, severity, status, human-friendly text
    X::Protocol::IPoUSPO.new(:200status).say;
    #-> IPoUSPO 2: 200 -- Delivered

    # The default .Str is just the stringified status.
    print X::Protocol::IPoUSPO.new(:400status), "\n";
    #-> 400

    # For one-offs you must supply a per-instance protocol name
    # The human readable text is optional 
    X::Protocol.new(:404status :protocol<HTTP> :human<Oops>).say;
    #-> "HTTP error: 404 -- Oops"

    # One-offs can also provide an override for the human message
    X::Protocol::IPoUSPO.new(:200status :human<OK>).say;
    #-> IPoUSPO 2: 200 -- OK

    # By default unknown codes produce no human text
    X::Protocol::IPoUSPO.new(:201status).say;
    #-> IPoUSPO 2: 200

=end code
=end SYNOPSIS

=begin DESCRIPTION

The C<X::Protocol> superclass is a convenience for working with status results
in protocol code.  Other than the quick subclass creation with sensible
defaults, the primary convenience is the ability to smartmatch against
terse C<Str> and C<Numeric> literals, or against regular expressions.

Beyond that, the X::Protocol module repo serves as a place for
protocol-specific subclasses so that long lists of human-readable
error messages can be shared by different protocol implementations.

=end DESCRIPTION

# We just use this to provide a bottom value to nextsames
# in our provided methods.
class X::Protocol::Internal {
    method code-to-human { () };
}

class X::Protocol is X::Protocol::Internal is Exception {

    has $.status = "ad-hoc";
    has Str $.protocol = self.protocol;
    has Str $.human;

    method protocol {
        $!protocol || die "A protocol name is required";
    }

    method message (X::Protocol:D $:) {
        join(" -- ",
	    $!protocol ~ " " ~ self.severity ~ ": $.status",
	    self.code-to-human);
    }

    method codes { Map.new() }

    method code-to-human (X::Protocol:D $:) {
        self.human or self.codes{$.status} or nextsame;
    }

    method severity { "error" }

    method Numeric (X::Protocol:D $:) {
        +$.status // NaN;
    }

    method toss (X::Protocol:D $:) {
        given self.severity {
            when "failure" { self.fail }
            when "error" { self.throw }
            when "warning" { note(self.gist) }
	    default { }
        }
    }

    method Str (X::Protocol:D $:) {
        ~$.status // "";
    }

}

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2015 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<Exception::(pm3)>
