=begin pod

=NAME HTML::Tag - Simple HTML Tag Generators

=SYNOPSIS

    =begin code
    use HTML::Tag::Tags;

    say HTML::Tag::p.new(:text('This is my paragraph'), :class('pretty')).render;
    
    # <p class="pretty">This is my paragraph</p>

    my $link = HTML::Tag::a.new(:text('paragraph'),
                                :href('http://dom.com'));
    say HTML::Tag::p.new(:text("This is my ", $link, ".")),
                         :class('pretty')).render;
    
    # <p class="pretty">This is my <a href="http://dom.com">paragraph</a>.
    =end code

=DESCRIPTION

HTML::Tag::Tags provides little objects to generate HTML tags. Tags
that support :text have their string text encoded for HTML special
characters.

Tags that support :text also support "embedding" other tags inside
their :text by passing alternating string text and tag objects as a
list. Tag objects passed this way I<should not> have C<.render> called
on them first to avoid the HTML special characters being escaped.

Not all attributes of every HTML tag is supported, just the most
common. It enforces very little. It is meant to help minimize clutter
in code for those who are not using html template classes or who wish
to dynamically generate segments of html code.

Please see the POD documentation for each macro for more details on
macro use.

Also, an HTML::Tag::Exports can be used to export the symbol "tag"
into your scope which shortens HTML::Tag::<thing> creation to
tag('thing', |%opts)

=head1 TAGS

HTML::Tag::Tags will give you all tag classes defined. They can be
instantiated with HTML::Tag::<whatever>.new and take options matching
their normal html attributes.

Tags can be combined into one another by placing them into another
tag's :text attribute. Tags are then recursively rendered when .render
is called on the furthest-outward containing tag (such as
HTML::Tag::html which represents an entire page).

C<HTML::Tag::Macro::CSS> will generate a CSS link.

C<HTML::Tag::Macro::Table> will help generate tables.

C<HTML::Tag::Macro::List> will help generate lists.

C<HTML::Tag::Macro::Form> will help generate form and do some form
variable handling.

=head1 MACROS

Please see individual macro files for more thorough documentation on
each macro.

=head2 HTML::Tag::Macro::CSS

Renders a normal CSS file link that can be wrapped into a html head element:

HTML::Tag::Macro::CSS.new(:href('/css/mycssfile.css')).render;


=head2 HTML::Tag::Macro::Table

A HTML::Tag::Macro::Table object gets fed rows one after the
other. These rows contain arrays of data that will be surrounded by
td's.

  =begin code
  my $table = HTML::Tag::Macro::Table.new;
  my @data = $var1, $var2, $var3;
  $table.row(@data);
  @data = $var4, $var5, $var6;
  $table.row(@data);
  $table.render;
  =end code

The .row method takes Bool :$header which will generated th tags
instead of td tags for each array element (representing a table header
row).

The .row method takes Hash :$tr-opts which will apply normal
HTML::Tag::tr options to that row, as specified in :$tr-opts.

The .row method takes Hash :$td-opts which will apply normal
HTML::Tag::td options to td tags that are generated for that
row. B<$td-opts is keyed by the td array element> (see td-opts example
code below).

  =begin code
  $table = HTML::Tag::Macro::Table.new(:table-opts(id =>'myID'));
  @data = 'Col1', 'Col2', 'Col3';
  $table.row(:header(True), @data);
  @data = 11, 22, 33;
  $table.row(@data);
  @data = 111, 222, 333;
  my $td-opts = %(1 => {class => 'pretty'},
                  2 => {class => 'pretty',
                        id    => 'lastone'});
  $table.row(:td-opts($td-opts), @data);
  =end code

As you can see the new constructor takes :$table-opts that will be
passed along to the normal HTML::Tag::table object.

NO CHECKING IS PERFORMED FOR A CONSISTENT NUMBER OF ELEMENTS IN EACH
ROW

=head2 HTML::Tag::Macro::List

Generates an ordered or unordered HTML list from a supplied array, or
constructs the array for you by repeated calling of the item() method.

    =begin code
    my $list = HTML::Tag::Macro::List.new;
    $list.link(:to('http://somewhere'), :text('rainbows'));
    $list.link(:to('http://elsewhere'), :text('snails'), :class('highlight'));
    $list.render;

    # .. or ..

    my @fruit = 'fingers', 'sofa', 'airliner';
    my $html = HTML::Tag::Macro::List.new(:items(@fruit)).render;
    =end code

The lists have a special method called link() that makes HTML::Tag::a
links that are surrounded by list elements since this is a common way
to generate HTML menus.

=head2 HTML::Tag::Macro::Form

Generates forms based upon a definition variable passed in. This
variable must be an array of hashes.

The array of hashes represents one form element per hash in the
array. Labels are automatically generated for all form elements by
default.

The hash key represents the HTML name of the hash by default, and the
input variable if given, etc. That key's value represents options for
that form element.

    =begin code
    use HTML::Tag::Macro::Form;

    my $form = HTML::Tag::Macro::Form.new(:action('/hg/login/auth'),
                                          :input(%.input));
    $form.def = ({username => {}},
                 {password => { type => 'password' }},
                 {submit   => { value => 'Login',
                                type  => 'submit',
                                label => '' }}
                );

    $form.render;
    =end code

Most certainly a work in progress.

=head1 AUTHOR

Mark Rushing mark@orbislumen.net

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
