use v6;

use PDF:ver(v0.2.1+);

#| PDF entry-point. either a trailer dict or an XRef stream
class PDF::Class:ver<0.1.6> #:api<PDF-1.7>
    is PDF {

    # base class declares: $.Size, $.Encrypt, $.ID
    use PDF::COS::Tie;
    use PDF::Class::Type;
    need PDF::Info;
    has PDF::Info $.Info is entry(:indirect);  #| (Optional; must be an indirect reference) The document’s information dictionary
    my subset Catalog of PDF::Class::Type where { .type eq 'Catalog' };  # autoloaded PDF::Catalog
    has Catalog $.Root is entry(:required, :indirect, :alias<catalog>);

    method type { 'PDF' }
    method version {
        Proxy.new(
            FETCH => sub ($) {
                Version.new: $.catalog<Version> // self.reader.?version // '1.4'
            },
            STORE => sub ($, Version $_) {
                my $name = .Str;
                $.catalog<Version> = PDF::COS.coerce: :$name;
            },
        );
    }

    method open(|c) {
	my $doc = callsame;
	die "PDF file has wrong type: " ~ $doc.reader.type
	    unless $doc.reader.type eq 'PDF';
	$doc;
    }

    method !preservation-needed {
        if self.reader and my $sig-flags = self.Root.?AcroForm.?SigFlags {
            constant AppendOnly = 2;
	    return $sig-flags.flag-is-set: AppendOnly
        }
        False;
    }

    method save-as($spec, Bool :$info = True, Bool :$preserve = self!preservation-needed, |c) {

        if $info {
            my $now = DateTime.now;
            my $Info = self.Info //= {};
            $Info.Producer //= "Perl 6 PDF::Class {self.^ver}";
            with self.reader {
                # updating
                $Info.ModDate = $now;
            }
            else {
                # creating
                $Info.CreationDate //= $now
            }
        }
	nextwith($spec, :!info, :$preserve, |c);
    }

    method update(Bool :$info = True, |c) {
        if $info {
            # for the benefit of the test suite
            my $now = DateTime.now;
            my $Info = self.Info //= {};
            $Info.ModDate = $now;
        }
        nextsame;
    }

    method cb-init {
        unless self<Root> {
	    self<Root> = { :Type( :name<Catalog> ) };
            self<Root>.cb-init;
        }
    }

    my subset Pages of PDF::Class::Type where { .type eq 'Pages' }; # autoloaded PDF::Pages
    method Pages returns Pages { self.Root.Pages }

    BEGIN for <page add-page delete-page insert-page page-count media-box crop-box bleed-box trim-box art-box core-font use-font> {
        $?CLASS.^add_method($_, method (|a) { self<Root><Pages>."$_"(|a) } );
    }

}
