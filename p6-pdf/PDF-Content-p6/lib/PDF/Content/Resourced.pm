use v6;

role PDF::Content::Resourced {

    method core-font(|c) {
	(self.Resources //= {}).core-font(|c);
    }

    #| ensure that object is registered as a resource
    method use-font($obj, |c) {
	(self.Resources //= {}).use-font($obj, |c);
    }
    method use-resource($obj, |c) {
	(self.Resources //= {}).resource($obj, |c);
    }
    method resource-key($obj, |c) {
	(self.Resources //= {}).resource-key($obj, |c);
    }

    #| my %fonts = $doc.page(1).resources('Font');
    multi method resources('ProcSet') {
	my @entries;
	my $resource-entries = .ProcSet with self.Resources;
	@entries = .keys.map( { $resource-entries[$_] } )
	    with $resource-entries;
	@entries;	
    }
    multi method resources(Str $type) is default {
	my %entries;
	my $resources = self.Resources;
	my Hash $resource-entries = $resources{$type}
	    if $resources && ($resources{$type}:exists);
	%entries = .keys.map( { $_ => $resource-entries{$_} } )
	    with $resource-entries;
	%entries;
    }

    method resource-entry(|c) {
        .resource-entry(|c) with self.Resources;
    }

    method find-resource(|c ) {
        .find-resource(|c)
            with self.Resources;
    }

    method images(Bool :$inline = True) {
	my %forms = self.resources: 'XObject';
	my @images = %forms.values.grep( *.<Subtype> eq 'Image');
	@images.append: self.gfx.inline-images
	    if $inline;
        @images;
    }

}
