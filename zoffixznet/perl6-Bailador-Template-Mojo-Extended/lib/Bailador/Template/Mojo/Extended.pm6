use Bailador::Template;

unit class Bailador::Template::Mojo::Extended:ver<2.001001>
    does Bailador::Template;

use Template::Mojo;
use Bailador;

my $param-str = '% my ( %s ) = @_; my $s = %s;' ~ "\n";
my $var-re = /^
    [ <:L> | '_' ]
    [
        <:L> | <:Nd> | '_' | <?after <:L>> <['-]> <?before <:L>>
    ]+
$/;

method render ($template is copy, *@params, *%params) {
    my %vars = _content => '';
    %vars{ $0 } = ~$1 while $template ~~ s/^ '%%' \s* (.+?) \s* ':' \s* (\N+) \n//;
    %vars = |%vars, |%params;

    die "Stash key `$_` cannot be used. It must be a valid variable name"
        for %vars.keys.grep: { $_ !~~ $var-re };

    die "Stash key `______pos` is reserved and cannot be used"
        if %vars<______pos>:exists;

    %vars<______pos> = @params;

    my $param-str = '% my ( %____ ) = @_;'
        ~ 'my @pos = %____<______pos>:delete;'
        ~ %vars.keys.sort.map({ "my \$$_ = \%____\<$_\>;" }).join
        ~ "\n";

    my $layout-file = $*SPEC.catdir(
        'views', 'layouts', (%vars<layout> || 'default') ~ '.tt'
    ).IO;

    die "Unable to find or read layout `$layout-file`"
        unless .r and .f given $layout-file;

    %vars<_content> = Template::Mojo.new($param-str ~ $template.chomp)
        .render: %vars;

    return Template::Mojo.new($param-str ~ $layout-file.slurp)
        .render: %vars;
}
