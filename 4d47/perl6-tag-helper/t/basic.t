use Test;
use Tag;

my $tag = Tag.new;

{
    # constructor accept an optional value argument
    is Tag.new, '';
    is Tag.new(:value('a')), 'a';
    is Tag.new(:value('<unescaped>')), '<unescaped>';
    is Tag.new(:value(Tag.new(:value('foo')))), 'foo';
}

{
    # class attributes are used to configure
    temp Tag.void-elements;
    temp Tag.self-closing-marker;
    temp Tag.boolean-attributes;
    is $tag.void-elements.elems, 16;
    $tag.void-elements.push('foo');
    is $tag.void-elements.elems, 17;
    is Tag.new.void-elements.elems, 17;
    Tag.self-closing-marker = '/';
    is $tag.self-closing-marker, '/';
}

{
    # instance accepts any methods with any number of arguments
    is $tag.br, '<br>';
    is $tag.p, '<p></p>';
    is $tag.p('foo'), '<p>foo</p>';
    is $tag.p('foo', 'bar'), '<p>foo bar</p>';
    is $tag.p('1 > 2'), '<p>1 &gt; 2</p>';
    is $tag.p(1, '>', 2), '<p>1 &gt; 2</p>';
    is $tag.p($tag.img), '<p><img></p>';
}

{
    # named parameters means tag attributes
    is $tag.hr(:class<foo>), '<hr class="foo">';
    is $tag.img(:src<a.jpg>, :alt('1 > 2')), '<img src="a.jpg" alt="1 &gt; 2">';
}

{
    # boolean attributes can be used with named parameters
    is $tag.input(:disabled), '<input disabled>';
    is $tag.input(:!disabled), '<input>';
}

{
    # void elements discard there inner content
    is $tag.img('should', 'ignore'), '<img>';
}

{
    # methods starting with `begin_` output only opening tag
    is $tag.begin_form, '<form>';
    is $tag.begin_form('should', 'ignore'), '<form>';
    is $tag.begin_form(:method<POST>), '<form method="POST">';
}

{
    # methods starting with `end_` output only closing tag
    is $tag.end_form, '</form>';
    is $tag.end_form('should', 'ignore'), '</form>';
    is $tag.end_form(:class<foo>, 'foo'), '</form>';
}

{
    # return value is a Tag object and not a Str
    is $tag.div($tag.br.br.br), '<div><br><br><br></div>';
}

{
    # methods can be called statically
    is Tag.b('hello'), '<b>hello</b>';
    is Tag.begin_form(:action<.>, :method<POST>), '<form action="." method="POST">';
}

{
    # void elements option
    temp Tag.void-elements;
    is Tag.p, '<p></p>';
    Tag.void-elements.push('p');
    is Tag.p, '<p>';
}

{
    # self closing marker option
    temp Tag.self-closing-marker;
    Tag.self-closing-marker = ' /';
    is Tag.br, '<br />';
    is Tag.img(:src<a.jpg>), '<img src="a.jpg" />';
    is Tag.p, '<p></p>';
}

{
    # boolean attributes option
    temp Tag.boolean-attributes;
    temp Tag.self-closing-marker;
    is Tag.input(:disabled), '<input disabled>';
    is Tag.input(:a), '<input a="True">';
    Tag.boolean-attributes.push('a');
    is Tag.input(:a), '<input a>';
    Tag.self-closing-marker = ' /';
    is Tag.input(:disabled), '<input disabled="disabled" />';
}

{
    # array content is flatten
    my @data = <a b c>.map({ Tag.li($^a) });
    is Tag.ul(:id<abc>, @data), '<ul id="abc"><li>a</li> <li>b</li> <li>c</li></ul>';
}

# fooling around with syntax
{
    is  (
        Tag.html:
            Tag.head:
                Tag.meta: :charset<UTF-8>
        ),
        '<html><head><meta charset="UTF-8"></head></html>';

    is Tag.div(Tag.a(:href('http://google.com'), 'Hello')), '<div><a href="http://google.com">Hello</a></div>';

    is (
        given Tag {
            .div(
                :class<header>,
                .a(:href('http://perl6.org'), 'Perl6'),
                'website'
            )
        }
    ), '<div class="header"><a href="http://perl6.org">Perl6</a> website</div>';

}


done;
