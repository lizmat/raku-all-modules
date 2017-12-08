unit class Pod::To::Markdown::Fenced;

die "!!! THIS MODULE IS DEPRECATED !!! Use `Pod::To::Markdown` instead.";

use Pod::To::Markdown;

multi sub pod2markdown(Pod::Block::Code $pad) is export is default {
    my $info = $pad.config<info> // '';
    return "```$info\n" ~
      $pad.contents».&pod2markdown.join.trim-trailing
      ~ "\n```"
}

method render($pod) {
    pod2markdown($pod);
}

