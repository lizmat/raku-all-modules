use v6;
use Zef;
use Net::HTTP::POST;

class Zef::CPANReporter does Messenger does Reporter {

    method !config     { state $config = $*HOME.child(q|.cpanreporter/config.ini|).lines>>.split("=") }
    method !email_from { state $email_from = self!config.grep( *[0] eq "email_from" ).map( *[1] )[0] }

    method report($event) {
        my $candi := $event.<payload>;

        my $report-json = to-json({
            :reporter({
                :email( self!email_from )
            }),
            :environment({
                # TODO include ^ver on the user_agent as soon as we
                # can get it from META6.json
                :user_agent( $?PACKAGE ~ ($?PACKAGE.^ver // '*') ),
                :language({
                    :name('Perl 6'),
                    :implementation($*PERL.compiler.name),
                    :version($*PERL.compiler.version.Str),
                    :backend({
                        :engine($*VM.name),
                        :version($*VM.version.Str)
                    }),
                    :archname( join '-', $*KERNEL.hardware, $*KERNEL.name ),
                    :variables({
                        '$*REPO.repo-chain' => $*REPO.repo-chain.Str,
                    }),
                    # TODO include critical distributions that are bundled
                    # to either rakudo or zef. Right now I'm not sure what's
                    # the best way to achieve this. The versions below should
                    # be the versions that were used to test/install the dist.
                    # :toolchain({
                    #    'zef' => version
                    #    'TAP' => version
                    # }),
                    # TODO uncomment --> :build(Compiler.verbose-config.Str),
                }),
                :system({
                    :osname($*KERNEL.name),
                    :osversion($*KERNEL.version.Str),
                    :variables({
                        :PATH(%*ENV<PATH>.Str),
                        %*ENV.grep( *.key.starts-with("PERL" | "RAKUDO") ),
                    }),

                    # TODO add those once they become available:
                    # :hostname(Str),        # hostname
                    # :cpu_count(Str),       # how many CPUs and cores do we have
                    # :cpu_type(Str),        # e.g. 'Intel Core i5'
                    # :cpu_description(Str), # e.g. 'MacBook Air (1.3 GHz)
                    # :filesystem(Str),      # FS where dist was tested
                }),
            }),
            :result({
                :grade(?$candi.test-results.map(*.so).all ?? 'pass' !! 'fail' ),
                :output(
                    hash
                    map  { $_ => $candi."{$_}-results"().Str   },
                    grep { $candi.^find_method("{$_}-results") },
                    <configure build test install>
                ),
                # TODO we'd love to send:
                # :tests(Int),    # number of tests that ran (tests, not test files)
                # :failures(Int), # how many test failures
                # :skipped(Int),  # how many tests were skipped
                # :todo({
                #    :pass(Int), # how many tests marked as TODO have passed
                #    :fail(Int), # how many tests marked as TODO have failed
                # }),
                # :warnings(Int), # did we get any warnings? If so, how many?
                # :duration(Int), # how long did it take us to run the tests, in seconds
            }),
            :distribution({
                :name($candi.dist.name),
                :version(first *.defined, $candi.dist.meta<ver version>),

                # TODO we'd love to traverse through
                # $candi.dist.meta<depends> and turn it into (expected JSON):
                # [
                #   { "phase": "test", "name": "Some::Dist", "need": "0.1", "have": "3.2" },
                #   { "phase": "build", "name": "Other::Dist", "need": "1.23", "have": "1.77" },
                # ]
            }),
        });

        my $response = Net::HTTP::POST("http://api.cpantesters.org/v3/report", body => $report-json);
        my $test-id  = try { from-json( $response.content(:force) )<id> };

        $test-id
            ?? $.stdout.emit("Report for {$event<payload>.dist.identity} will be available at http://cpantesters.org/report/{$test-id}")
            !! $.stderr.emit("Encountered problems sending test report for {$event<payload>.dist.identity}");

        return $test-id;
    }
}

=begin pod

=head1 NAME

Zef::CPANReporter - send Perl 6 reports to CPAN Testers (using zef)

=head1 DESCRIPTION

Zef::CPANReporter is a module to send installation success/failure reports to CPAN Testers.

=head1 AUTHORS

Breno G. de Oliveira (GARU)
Nick Logan (UGEXE)

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Breno G. de Oliveira, Nick Logan

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
