use v6;
use Prompt::Gruff;

unit class Prompt::Gruff::Export;

sub prompt-for($prompt, *%opts) is export {
    Prompt::Gruff.new.prompt-for($prompt, |%opts);
}

=begin pod

=head1 NAME Prompt::Gruff::Export

=head1 SYNOPSIS

    =begin code :skip-test
    use Prompt::Gruff::Export

    $answer = prompt-for("Name: ");

    # See Prompt::Gruff for details on options/attributes
    =end code

=head1 DESCRIPTION

This only exports "prompt-gruff" into your namespace so that you don't
have to keep making objects to use it.

Please see the documentation for Prompt::Gruff to get the details.

=head1 AUTHOR

Mark Rushing mark@orbislumen.net

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
