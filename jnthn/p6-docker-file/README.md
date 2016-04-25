# Docker::File

A Perl 6 module to read/write docker files.

## Synopsis

    # Parse a Dockerfile into a bunch of objects.
    my $parsed-df = Docker::File.parse($docker-file);
    unless $parsed-df.instructions.grep(Docker::File::Maintainer) {
        note "This Dockerfile has no maintainer! :-("
    }
    
    # Generate a Dockerfile.
    my $new-df = Docker::File.new(
        images => [
            Docker::File::Image.new(
                from-short => 'ubuntu',
                from-tag => 'latest'
                entries => [
                    Docker::File::RunShell.new(
                        command => 'sudo apt-get install perl6'
                    )
                ]
            )
        ]
    );
    say ~$new-df;
