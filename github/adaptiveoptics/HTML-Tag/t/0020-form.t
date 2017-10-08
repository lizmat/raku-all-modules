use v6;
use Test; 
use lib <lib>;

plan 23;

use-ok 'HTML::Tag::Tags', 'HTML::Tag::Tags can be use-d';
use HTML::Tag::Tags;
use-ok 'HTML::Tag::Macro::Form', 'HTML::Tag::Macro::Form can be use-d';
use HTML::Tag::Macro::Form;

ok my $form = HTML::Tag::Macro::Form.new(:nolabel, :action('/')), 'HTML::Tag::Macro::Form instantated';

my @def = ( { username => { }},
	    { password => { }},
	    { submit   => { type  => 'submit',
			    value => 'Login', }},
	  );

$form.def = @def;

is $form.render, '<form method="POST" name="form" action="/"><input name="username" id="form-username" type="text"><input name="password" id="form-password" type="text"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form minimal def';

@def = ( { username => { autofocus => True }},
	 { password => { }},
	 { submit   => { type  => 'submit',
			 value => 'Login', }},
       );

$form.def = @def;

is $form.render, '<form method="POST" name="form" action="/"><input name="username" id="form-username" type="text" autofocus><input name="password" id="form-password" type="text"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form autofocus';

ok $form = HTML::Tag::Macro::Form.new(:def(@def), :action('/')), 'HTML::Tag::Macro::Form def passed directly in';

is $form.render, '<form method="POST" name="form" action="/"><label for="form-username">Username</label><input name="username" id="form-username" type="text" autofocus><label for="form-password">Password</label><input name="password" id="form-password" type="text"><label for="form-submit">Submit</label><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form with labels';

@def = ( { username => { }},
	 { password => { }},
	 { submit   => { type    => 'submit',
			 value   => 'Login',
			 nolabel => 1 }},
       );

$form.def = @def;

is $form.render, '<form method="POST" name="form" action="/"><label for="form-username">Username</label><input name="username" id="form-username" type="text"><label for="form-password">Password</label><input name="password" id="form-password" type="text"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form with labels excluding one';

my %input;
%input<username> = 'mark';

ok $form = HTML::Tag::Macro::Form.new(:nolabel, :input(%input), :def(@def), :action('/')), 'HTML::Tag::Macro::Form input values instatiate';

is $form.render, '<form method="POST" name="form" action="/"><input name="username" id="form-username" type="text" value="mark"><input name="password" id="form-password" type="text"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form with value test';

@def = ( { username => { }},
	 { password => { type => 'password' }},
	 { submit   => { type    => 'submit',
			 value   => 'Login',
			 nolabel => 1 }},
       );

%input<username> = 'mark';
%input<password> = 'supersecret';

ok $form = HTML::Tag::Macro::Form.new(:input(%input), :def(@def), :action('/')), 'HTML::Tag::Macro::Form input values instatiate for pw test';

is $form.render, '<form method="POST" name="form" action="/"><label for="form-username">Username</label><input name="username" id="form-username" type="text" value="mark"><label for="form-password">Password</label><input name="password" id="form-password" type="password"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form with value test password types set no values';

my $tag-after = HTML::Tag::br.new;
my $tag-before = HTML::Tag::span.new(:text('oofie'));

@def = ( { username => { tag-after => $tag-after }},
	 { password => { type => 'password' }},
	 { submit   => { type    => 'submit',
			 value   => 'Login',
			 nolabel => 1,
			 tag-before => $tag-before }},
       );

ok $form = HTML::Tag::Macro::Form.new(:input(%input), :def(@def), :action('/')), 'HTML::Tag::Macro::Form input values instatiate for tags before/after';

is $form.render, '<form method="POST" name="form" action="/"><label for="form-username">Username</label><input name="username" id="form-username" type="text" value="mark"><br><label for="form-password">Password</label><input name="password" id="form-password" type="password"><span>oofie</span><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form testing before/after tags';

@def = ( { username => { swallowed-by => $tag-before }},
	 { password => { type => 'password' }},
	 { submit   => { type    => 'submit',
			 value   => 'Login',
			 nolabel => 1 }},
       );

ok $form = HTML::Tag::Macro::Form.new(:input(%input), :def(@def), :action('/')), 'HTML::Tag::Macro::Form input values instatiate for input swallowing';

is $form.render, '<form method="POST" name="form" action="/"><span>oofie<label for="form-username">Username</label><input name="username" id="form-username" type="text" value="mark"></span><label for="form-password">Password</label><input name="password" id="form-password" type="password"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form input swallowing';


ok $form = HTML::Tag::Macro::Form.new(:nolabel, :action('/')), 'HTML::Tag::Macro::Form for required test instantated';

@def = ( { username => { required => True }},
	 { password => { }},
	 { submit   => { type  => 'submit',
			 value => 'Login', }},
       );

$form.def = @def;

is $form.render, '<form method="POST" name="form" action="/"><input name="username" id="form-username" type="text" required><input name="password" id="form-password" type="text"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form required fields';

$form = HTML::Tag::Macro::Form.new(:nolabel, :action('/'));

@def = ( { username => { attrs => {:class('pink')} }},
	 { password => { attrs => {:id('blue')} }},
	 { submit   => { type  => 'submit',
			 value => 'Login', }},
       );

$form.def = @def;

is $form.render, '<form method="POST" name="form" action="/"><input name="username" id="form-username" class="pink" type="text"><input name="password" id="blue" type="text"><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form using individual/normal tag attrs';

$form = HTML::Tag::Macro::Form.new(:nolabel, :action('/'));

@def = ( { username => { }},
	    { password => { }},
	    { notes    => { type => 'textarea' }},
	    { submit   => { type  => 'submit',
			    value => 'Login', }},
	  );

$form.def = @def;

is $form.render, '<form method="POST" name="form" action="/"><input name="username" id="form-username" type="text"><input name="password" id="form-password" type="text"><textarea name="notes" id="form-notes"></textarea><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form empty textarea';

$form = HTML::Tag::Macro::Form.new(:nolabel, :action('/'));

@def = ( { username => { }},
	 { password => { }},
	 { notes    => { type  => 'textarea',
			 attrs => {text => 'I am a test'} }},
	 { submit   => { type  => 'submit',
			 value => 'Login', }},
       );

$form.def = @def;

is $form.render, '<form method="POST" name="form" action="/"><input name="username" id="form-username" type="text"><input name="password" id="form-password" type="text"><textarea name="notes" id="form-notes">I am a test</textarea><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form textarea with text';

%input = notes => 'do not forget';

$form = HTML::Tag::Macro::Form.new(:nolabel, :input(%input), :action('/'));

@def = ( { username => { }},
	 { password => { }},
	 { notes    => { type  => 'textarea',
			 attrs => {text => 'I am a test'} }},
	 { submit   => { type  => 'submit',
			 value => 'Login', }},
       );

$form.def = @def;

is $form.render, '<form method="POST" name="form" action="/"><input name="username" id="form-username" type="text"><input name="password" id="form-password" type="text"><textarea name="notes" id="form-notes">I am a test</textarea><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form textarea with text overrides value';

%input = notes => 'do not forget';

$form = HTML::Tag::Macro::Form.new(:nolabel, :input(%input), :action('/'));

@def = ( { username => { }},
	 { password => { }},
	 { notes    => { type  => 'textarea' }},
	 { submit   => { type  => 'submit',
			 value => 'Login', }},
       );

$form.def = @def;

is $form.render, '<form method="POST" name="form" action="/"><input name="username" id="form-username" type="text"><input name="password" id="form-password" type="text"><textarea name="notes" id="form-notes">do not forget</textarea><input name="submit" id="form-submit" type="submit" value="Login"></form>', 'HTML::Tag::Macro::Form textarea values work';

