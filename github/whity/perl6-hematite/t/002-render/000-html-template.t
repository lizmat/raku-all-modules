use v6;

use Test;
use HTTP::Request;
use Template::Mustache;
use Crust::Test;
use Hematite;

sub MAIN() {
    my $templates_dir  = get-templates-dir();
    my %templates_data = (name => 'world');
    my %templates      = read-all-templates($templates_dir, %templates_data);

    my $app = Hematite.new(
        templates => {
            directory => $templates_dir,
        },
    );

    $app.GET('/file', sub ($ctx) { $ctx.render('html', data => %templates_data); } );

    $app.GET('/inline', sub ($ctx) {
        $ctx.render(
            'hi {{ name }}',
            inline => True,
            data   => %templates_data,
        );

        return;
    } );

    $app.GET('/file-with-partial', sub ($ctx) {
        $ctx.render(
            'html-with-partial',
            data => %templates_data,
        );
        return;
    } );

    $app.GET('/inline-with-partial', sub ($ctx) {
        $ctx.render(
            'hi {{ name }}, {{> partial}}',
            inline => True,
            data   => %templates_data,
        );
        return;
    } );

    # create the test handler
    my $test = Crust::Test.create(sub ($env) { start { $app($env); }; });

    # TEST: render file
    {
        my $res = $test.request(HTTP::Request.new(GET => "/file"));
        is($res.content.decode, %templates{'html.mustache'}, 'render file');
    }

    # TEST: render inline
    {
        my $res = $test.request(HTTP::Request.new(GET => "/inline"));
        is($res.content.decode, 'hi world', 'render inline');
    }

    # TEST: render file-with-partial (file and inline)
    {
        my $res = $test.request(HTTP::Request.new(GET => "/file-with-partial"));
        is($res.content.decode, %templates{'html-with-partial.mustache'}, 'render file with partial');
    }

    # TEST: render inline-with-partial (file and inline)
    {
        my $res = $test.request(HTTP::Request.new(GET => "/inline-with-partial"));
        is($res.content.decode, 'hi world, ' ~ %templates{'partial.mustache'}, 'render inline with partial');
    }

    done-testing;

    return;
}

sub get-templates-dir() {
    my $cur_dirname = IO::Path.new($?FILE).dirname;
    return $cur_dirname ~ '/templates';
}

sub read-all-templates(Str $templates_dir, %data) {
    my @files     = $templates_dir.IO.dir;
    my %templates = ();
    for @files -> $file {
        my $filename = $file.IO.basename;

        my $contents = Template::Mustache.render(
            $file.IO.slurp,
            %data.clone,
            from => [$templates_dir]
        );

        %templates{$filename} = $contents;
    }

    return %templates;
}
