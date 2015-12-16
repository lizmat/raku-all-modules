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
in protocol code.  It allows one to reap the benefits of typed exceptions
without having to type out their names very often.  You simply feed the
error code from the protocol in as an argument to X::Protocol.new (or,
more usually, to a subclass) and it is automatically paired with a human
readable error message, producing an object that can be printed, thrown,
or inspected.

One can easily tell a protocol error apart from an internal code error
by whether it matches C<X::Protocol>, and tell which protocol an error came
from either by looking at the C<.protocol> attribute, or checking which
subclass it belongs to.

Better yet, you can simply smart match the object against integers, strings
and regular expressions in your error handling code.

For commonly used protocols, the X::Protocol module repo serves as a place
for protocol-specific subclasses to store long lists of human-readable
error messages so they can be shared by different protocol implementations
and maintained in one place.

=end DESCRIPTION

# We just use this to provide a bottom value to nextsames
# in our provided methods.
class X::Protocol::Internal {
    method code-to-human { () };
}

#| A base class which can also be used directly if there is no subclass
#| for the protocol being implemented.
class X::Protocol is X::Protocol::Internal is Exception {

=begin ATTRIBUTES
An instance of this base class has only three actual attributes:  

=item1 C<.status>   -- the machine-friendly status code a protocol produced.
=item1 C<.human>    -- an optional override to the human-readable message.
=item1 C<!protocol> -- the name of the protocol, usually set by default.

=end ATTRIBUTES

    has $.status = "ad-hoc";
    has Str $.protocol = self.protocol;
    has Str $.human;

    method protocol {
        $!protocol || die "A protocol name is required";
    }

    #| A string showing the protocol, severity, status code and message
    method message (X::Protocol:D $:) {
        join(" -- ",
	    $!protocol ~ " " ~ self.severity ~ ": $.status",
	    self.code-to-human);
    }

    #| Class method returning a C<Map> of error codes to human readable messages
    method codes { Map.new() }

    #| The human readable message from $.human, or a code-specific default
    method code-to-human (X::Protocol:D $:) {
        self.human or self.codes{$.status} or nextsame;
    }

    #| A string classifying the error into a category.  May be used by C<.toss>.
    method severity { "error" }

    #| Performs default action based on the exception, such as throwing,
    #| returning a C<Failure>, printing a warning, or nothing.  This can be
    #| highly subclass-specific -- the base class checks C<.severity> to see
    #| if it contains "error", "failure", or "warning".  Of course, you
    #| may override this method or C<.severity> locally by subclassing.
    method toss (X::Protocol:D $:) {
        given self.severity {
            when "failure" { self.fail }
            when "error" { self.throw }
            when "warning" { note(self.gist) }
	    default { }
        }
    }

    #| Attempts to cast C<.code> to C<Numeric> or returns NaN.
    method Numeric (X::Protocol:D $:) {
        +$.status // NaN;
    }

    #| Attempts to cast C<.code> to C<Str> or returns an empty string.
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
