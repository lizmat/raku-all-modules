use v6;

=begin pod

=head1 NAME

Lumberjack::Template::Provider - Template6::Provider to get template from %?RESOURCES

=head1 DESCRIPTION

This is a C<Template6::Provider> implementation that is used
internally by C<Lumberjack::Application::Index> to serve up
a template from C<%?RESOURCES>.  As it is currently implemented
it is not immediately useful outside the distribution because
the resources are "compiled in". I may move the functionality
to C<Template6> later when I have worked out how to overcome
that little problem.

=end pod

use Template6::Provider;

class Lumberjack::Template::Provider does Template6::Provider {

    method fetch($name --> Str) {
        my Str $template;
        if %.templates{$name}:exists {
            $template =  %.templates{$name};
        }
        else {
            for @!include-path -> $path {
                my $file = "$path/$name" ~ ($name.ends-with($.ext) ?? '' !! $.ext);
                if %?RESOURCES{$file}.IO.e {
                    $template = %?RESOURCES{$file}.slurp;
                    %.templates{$name} = $template;
                    last;
                }
            }
        }
        return $template;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
