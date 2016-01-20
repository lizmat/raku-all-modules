use v6;
use XML;

sub MAIN($schema-file?) {

	my $doc = from-xml-file($schema-file // '3rd-party/xhtml1-strict.xsd');

	my %attr-group;

	multi sub walk(XML::Text, *%named){} # NOOP

	multi sub walk(XML::Element $_ where .name ~~ <xs:attributeGroup>){
		.nodes>>.&walk(group-name=>.attribs<name>);
	}

	multi sub walk(XML::Element $_ where .name ~~ <xs:attributeGroup>, :$group-name){
		my $ref = .attribs<ref> // Failure.new;
		%attr-group{$group-name}.push: |%attr-group{$ref};
		.nodes>>.&walk(group-name=>.attribs<name>);
	}

	multi sub walk(XML::Element $_ where .name ~~ <xs:attribute>, :$group-name!){
		my $name = .attribs<name> // .attribs<ref> // Failure.new;
		%attr-group.push($group-name=>$name);
		.nodes>>.&walk(:$group-name);
	}

	my %elements;
	put 'use v6;';
	put 'use Typesafe::HTML;';
	put 'my $indent = 0;' ~ "\n";
	put 'constant NL = "\n";';
	put 'my $Guard = HTML;';
	put 'my Bool $shall-indent = True;';
	multi sub walk(XML::Element $_ where .name ~~ <xs:element> && (.attribs<name>:exists)) {
		my $name := .attribs<name> // Failure.new;
		%elements{$name} = Any;
		.nodes>>.&walk(element-name=>$name);		

		my Str $named-arguments = (':$' xx * Z~ %elements{$name}>>.subst(':', '-').list Z~ '?,' xx * ).Str;
		my Str $attributes-switch = %elements{$name}.list.map({
			"   (\${$_.subst(':', '-')} ?? ' $_' ~ '=' ~ \"\\\"\${$_.subst(':', '-')}\\\"\" !! Empty) ~\n" 	
		}).Str;

		# workaround for #127226
        constant $indent = '$indent';
		constant $e = '$e';
		constant $Guard = '$Guard';
        put qq:to/EOH/;
        sub $name ( $named-arguments *\@c --> HTML) is export(:ALL :$name) \{
            (temp \$indent)+=2;
            for \@c -> \$e is rw \{ \$e = \$Guard.new ~ \$e.Str unless \$e ~~ HTML \}
            \$Guard.new(
                '<$name' ~ 
                $attributes-switch 
                ( +\@c ?? ('>' ~ NL ~ (\$shall-indent ?? \@c>>.Str>>.indent(\$indent).join(NL) !! \@c>>.Str.join(NL) )~ (+\@c ?? NL !! "") ~ '</$name>') 
                      !! '/>' )
            )
        \}
        
        EOH
	}

	multi sub walk(XML::Element $_ where .name ~~ <xs:attribute>, :$element-name!) {
		my $name = .attribs<name> // .attribs<ref> // Failure.new;
		%elements{$element-name}.push: |$name;
	}

	multi sub walk(XML::Element $_ where .name ~~ <xs:attributeGroup>, :$element-name!) {
		%elements{$element-name}.push: |%attr-group{.attribs<ref>};
	}

	multi sub walk(XML::Element $_, *%named){
		.nodes>>.&walk(|%named);
	}

	multi sub walk(*@_, *%named) {
		.nodes>>.&walk(|%named);
	}

	$doc.root.nodes>>.&walk;
	put Q:to/END/;
	sub writer-shall-indent(Bool $shall-it) is export(:ALL :writer-shall-indent) { $shall-indent = $shall-it }
	sub EXPORT(::Guard = HTML) {
		$Guard = Guard;
		{
			Guard => $Guard,
	    }
	}
	END
}
