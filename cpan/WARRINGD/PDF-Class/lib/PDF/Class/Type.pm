use v6;

# autoload from PDF::Class::Type

role PDF::Class::Type[$type-entry = 'Type', $subtype-entry = 'Subtype'] {

    use PDF::Class::Loader;
    use PDF::COS;
    #| enforce tie-ins between /Type, /Subtype & the class name. e.g.
    #| PDF::Catalog should have /Type = /Catalog
    method type    is rw { self{$type-entry} }
    method subtype is rw { self{$subtype-entry} }

    method cb-init {
        for self.^mro {
            my Str $class-name = .^name;

            if $class-name ~~ /^ 'PDF::' (\w+) ['::' (\w+)]? $/ {
                my Str $type-name = ~$0;

		my $type = self.type //= PDF::COS.coerce( :name($type-name) );

		# /Type already set. check it agrees with the class name
		die "conflict between class-name $class-name ($type-name) and dictionary /$type-entry /{self{$type-entry}}"
		    unless $type eq $type-name;

                if $1 {
                    my Str $subtype-name = ~$1;
		    my $subtype = self.subtype //= PDF::COS.coerce( :name($subtype-name) );

		    # /Subtype already set. check it agrees with the class name
		    die "conflict between class-name $class-name ($subtype-name) and dictionary /$subtype-entry /{self{$subtype-entry}}"
			unless $subtype eq $subtype-name;
                }

                last;
            }
        }

    }

}
