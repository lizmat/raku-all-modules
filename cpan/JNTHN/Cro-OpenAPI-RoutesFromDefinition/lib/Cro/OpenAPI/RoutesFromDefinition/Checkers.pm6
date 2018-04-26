use Cro::HTTP::Request;
use Cro::HTTP::Response;
use OpenAPI::Schema::Validate;

class X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed is Exception {
    has Cro::HTTP::Message $.http-message is required;
    has Str $.reason is required;
    has Bool $.bad-path = False;
    method message() {
        my $what = $!http-message ~~ Cro::HTTP::Request ?? 'request' !! 'response';
        "OpenAPI $what validation failed: $!reason"
    }
}

package Cro::OpenAPI::RoutesFromDefinition {
    role Checker {
        method check(Cro::HTTP::Message $m, Any $body --> Nil) { ... }
        method requires-body(--> Bool) { ... }
    }

    class AllChecker does Checker {
        has Checker @.checkers;
        method check(Cro::HTTP::Message $m, $body --> Nil) {
            .check($m, $body) for @!checkers;
        }
        method requires-body(--> Bool) {
            so any(@!checkers>>.requires-body)
        }
    }

    class BodyChecker does Checker {
        has Bool $.write;
        has Bool $.read;
        has Bool $.required;
        has %!content-type-schemas;
        submethod TWEAK(:%content-schemas, :%validate-options --> Nil) {
            for %content-schemas.kv -> $type, $schema {
                %!content-type-schemas{$type.fc} = $schema
                    ?? OpenAPI::Schema::Validate.new(:$schema, |%validate-options)
                    !! Nil;
            }
        }
        method check(Cro::HTTP::Message $m, $body --> Nil) {
            if $m.header('content-type') -> $content-type {
                if %!content-type-schemas{$content-type.fc}:exists {
                    with %!content-type-schemas{$content-type.fc} {
                        .validate($body, :$!read, :$!write);
                        CATCH {
                            when X::OpenAPI::Schema::Validate::Failed {
                                die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                                    http-message => $m,
                                    reason => "validation of '$content-type' schema failed " ~
                                        "at $_.path(): $_.reason()"
                                );
                            }
                        }
                    }
                }
                else {
                    die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                        http-message => $m,
                        reason => "content type '$content-type' is not allowed"
                    );
                }
            }
            elsif $!required {
                die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                    http-message => $m,
                    reason => "a message body is required"
                );
            }
        }
        method requires-body(--> Bool) {
            True
        }
    }

    class QueryStringChecker does Checker {
        has %!required;
        has %!expected;
        has %!schemas;
        method TWEAK(:@parameters, :%validate-options) {
            for @parameters {
                %!expected{.name} = True;
                %!required{.name} = True if .required;
                if .schema -> $schema {
                    %!schemas{.name} = OpenAPI::Schema::Validate.new(:$schema, |%validate-options);
                }
            }
        }
        method check(Cro::HTTP::Message $m, $ --> Nil) {
            my %required-unseen = %!required;
            for $m.query-hash.kv -> $name, $value {
                unless %!expected{$name}:exists {
                    die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                        http-message => $m,
                        reason => "unexpected query string parameter '$name'"
                    );
                }
                %required-unseen{$name}:delete;
                with %!schemas{$name} {
                    my $result = .validate($value);
                    unless $result {
                        $result = .validate(val($value));
                    }
                    unless $result {
                        given $result.exception {
                            die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                                http-message => $m,
                                reason => "validation of '$name' query string parameter " ~
                                          "schema failed at $_.path(): $_.reason()"
                            );
                        }
                    }
                }
            }
            if %required-unseen {
                die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                    http-message => $m,
                    reason => "missing required query string parameter '{%required-unseen.keys[0]}'"
                );
            }
        }
        method requires-body(--> Bool) {
            False
        }
    }

    class HeaderChecker does Checker {
        has %!required;
        has %!schemas;
        method TWEAK(:@parameters, :%validate-options) {
            for @parameters {
                %!required{.name} = True if .required;
                if .schema -> $schema {
                    %!schemas{.name} = OpenAPI::Schema::Validate.new(:$schema, |%validate-options);
                }
            }
        }
        method check(Cro::HTTP::Message $m, $ --> Nil) {
            my %required-unseen = %!required;
            for $m.headers.map(*.name).unique -> $name {
                %required-unseen{$name}:delete;
                with %!schemas{$name} {
                    my $value = $m.header($name);
                    my $result = .validate($value);
                    unless $result {
                        $result = .validate(val($value));
                    }
                    unless $result {
                        given $result.exception {
                            die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                                http-message => $m,
                                reason => "validation of '$name' header " ~
                                          "schema failed at $_.path(): $_.reason()"
                            );
                        }
                    }
                }
            }
            if %required-unseen {
                die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                    http-message => $m,
                    reason => "missing required header '{%required-unseen.keys[0]}'"
                );
            }
        }
        method requires-body(--> Bool) {
            False
        }
    }

    class CookieChecker does Checker {
        has %!required;
        has %!schemas;
        method TWEAK(:@parameters, :%validate-options) {
            for @parameters {
                %!required{.name} = True if .required;
                if .schema -> $schema {
                    %!schemas{.name} = OpenAPI::Schema::Validate.new(:$schema, |%validate-options);
                }
            }
        }
        method check(Cro::HTTP::Message $m, $ --> Nil) {
            my %required-unseen = %!required;
            for $m.cookie-hash.kv -> $name, $value {
                %required-unseen{$name}:delete;
                with %!schemas{$name} {
                    my $result = .validate($value);
                    unless $result {
                        $result = .validate(val($value));
                    }
                    unless $result {
                        given $result.exception {
                            die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                                http-message => $m,
                                reason => "validation of '$name' cookie " ~
                                          "schema failed at $_.path(): $_.reason()"
                            );
                        }
                    }
                }
            }
            if %required-unseen {
                die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                    http-message => $m,
                    reason => "missing required cookie '{%required-unseen.keys[0]}'"
                );
            }
        }
        method requires-body(--> Bool) {
            False
        }
    }

    class PathChecker does Checker {
        my class Check {
            has Str $.name;
            has Int $.index;
            has OpenAPI::Schema::Validate $.schema;
        }
        has Check @!checks;
        method TWEAK(:@parameters, :@template-segments, :%validate-options) {
            for @parameters -> $param {
                with @template-segments.first(:k, '{' ~ $param.name ~ '}') -> $index {
                    with $param.schema -> $schema {
                        push @!checks, Check.new(:$index, :name($param.name),
                            :schema(OpenAPI::Schema::Validate.new(:$schema, |%validate-options)));
                    }
                }
                else {
                    die "Template parameter '$param.name()' not found in template '/@template-segments.join('/')'";
                }
            }
        }
        method check(Cro::HTTP::Message $m, $ --> Nil) {
            my @segs = $m.path-segments;
            for @!checks -> $check {
                my $value = @segs[$check.index];
                my $result = $check.schema.validate($value);
                unless $result {
                    $result = $check.schema.validate(val($value));
                }
                unless $result {
                    given $result.exception {
                        die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                            http-message => $m,
                            bad-path => True,
                            reason => "validation of route segment '$check.name()' schema " ~
                                "failed at $_.path(): $_.reason()"
                        );
                    }
                }
            }
        }
        method requires-body(--> Bool) {
            False
        }
    }

    class ResponseChecker does Checker {
        has %.checker-by-code;
        method check(Cro::HTTP::Message $m, $body --> Nil) {
            with %!checker-by-code{$m.status} // %!checker-by-code<default> {
                .check($m, $body);
            }
            elsif $m.status != 500 {
                die X::Cro::OpenAPI::RoutesFromDefinition::CheckFailed.new(
                    http-message => $m,
                    reason => "this response may not produce status $m.status()"
                );
            }
        }
        method requires-body(--> Bool) {
            so any(%!checker-by-code.values).requires-body
        }
    }

    class PassChecker does Checker {
        method check($, $ --> Nil) {
            # Always accept
        }
        method requires-body(--> Bool) {
            False
        }
    }
}
