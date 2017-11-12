use v6;

role PDF::Content::ResourceDict {

    use PDF::DAO;
    use PDF::DAO::Name;
    use PDF::Content::Font;

    has Str %!resource-key; # {Any}
    has Int %!counter;

    method resource-key($object is copy, |c --> Str:D) {
        $object = $.resource($object, |c)
           unless %!resource-key{$object.WHICH};
       %!resource-key{$object.WHICH};
    }
    
    method !resource-type( PDF::DAO $_ ) is default {
        when Hash {
            when .<Type>:exists {
                given .<Type> {
                    when 'ExtGState'|'Font'|'XObject'|'Pattern' { $_ }
                }
            }
            when .<PatternType>:exists { 'Pattern' }
            when .<ShadingType>:exists { 'Shading' }
            when .<Subtype>:exists && .<Subtype> ~~ 'Form'|'Image'|'PS' {
                # XObject with /Type defaulted
                'XObject'
            }
        }
        when Array && .[0] ~~ PDF::DAO::Name {
            # e.g. [ /CalRGB << /WhitePoint [ 1.0 1.0 1.0 ] >> ]
            'ColorSpace'
        }
        default {
	    warn "unrecognised graphics resource object: {.perl}";
	    'Other'
        }
    }

    method find-resource( &match, Str :$type! ) {
        my $entry;

        with self{$type} -> $resources {

            for $resources.keys {
                my $resource = $resources{$_};
                if &match($resource) {
		    $entry = $resource;
		    %!resource-key{$entry.WHICH} = $_;
                    last;
                }
            }
        }

        $entry;
    }

    #| ensure that the object is registered as a page resource. Return a unique
    #| name for it.
    method !register-resource(PDF::DAO $object,
                             Str :$type = self!resource-type($object),
	) {

	my constant %Prefix = %(
	    :ColorSpace<CS>, :Font<F>, :ExtGState<GS>, :Pattern<Pt>,
            :Shading<Sh>, :XObject{  :Form<Fm>, :Image<Im>, :PS<PS> },
	    :Other<Obj>,
	);

	my $prefix = $type eq 'XObject'
	    ?? %Prefix{$type}{ $object<Subtype> }
	    !! %Prefix{$type};

        my Str $key;
        # make a unique resource key
        repeat {
            $key = $prefix ~ ++%!counter{$prefix};
        } while self.keys.first: { self{$_}{$key}:exists };

        self{$type}{$key} = $object;

	%!resource-key{$object.WHICH} = $key;
        $object;
    }

    multi method resource($object where %!resource-key{.WHICH} ) {
	$object;
    }

    multi method resource(PDF::DAO $object, Bool :$eqv=False ) is default {
        my Str $type = self!resource-type($object)
            // die "not a resource object: {$object.WHAT}";

	my &match = $eqv
	    ?? sub ($_){$_ eqv $object}
	    !! sub ($_){$_ === $object};
        self.find-resource(&match, :$type)
            // self!register-resource( $object );
    }

    method resource-entry(Str:D $type!, Str:D $key!) {
        .{$key} with self{$type};
    }

    method core-font(|c) {
        self.use-font: (require ::('PDF::Content::Font::CoreFont')).load-font( |c );
    }

    multi method use-font(PDF::Content::Font $font) {
        my $font-obj = $font.font-obj;
        self.find-resource(sub ($_){ .?font-obj === $font-obj },
			   :type<Font>)
            // self!register-resource( $font );
    }

    multi method use-font($font-obj) is default {
        self.find-resource(sub ($_){ .?font-obj === $font-obj },
			   :type<Font>)
            // self!register-resource: $font-obj.to-dict;
    }

}
