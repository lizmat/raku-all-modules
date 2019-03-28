use v6;

use PDF:ver(v0.3.2+);

#| PDF entry-point. either a trailer dict or an XRef stream
class PDF::Class:ver<0.3.5>#:api<PDF-1.7>
    is PDF {
    # See [PDF 32000 Table 15 - Entries in the file trailer dictionary]
    # base class declares: $.Size, $.Encrypt, $.ID
    ## use ISO_32000::File_trailer;
    ## also does ISO_32000::File_trailer;

    use PDF::COS::Tie;
    use PDF::Class::Type;
    use PDF::Info;
    has PDF::Info $.Info is entry(:indirect);  # (Optional; must be an indirect reference) The document’s information dictionary
    my subset Catalog of PDF::Class::Type where { .<Type> ~~ 'Catalog' };  # autoloaded PDF::Catalog
    has Catalog $.Root is entry(:required, :indirect, :alias<catalog>);

    method type { 'PDF' }
    method version is rw {
        Proxy.new(
            FETCH => {
                Version.new: $.catalog<Version> // self.?reader.?version // '1.4'
            },
            STORE => -> $, Version $_ {
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

    method save-as($spec, Bool :$info = True, |c) {

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
	nextwith($spec, :!info, |c);
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

    # permissions check, e.g: $doc.permitted( PermissionsFlag::Modify )
    method permitted(UInt $flag --> Bool) {

	my Int $perms = self.Encrypt.?P
	    // return True;

	return True
	    if $.crypt.?is-owner;

	return $perms.flag-is-set( $flag );
    }

    method cb-init {
        unless self<Root> {
	    self<Root> = { :Type( :name<Catalog> ) };
            self<Root>.cb-init;
        }
    }

    my subset Pages of PDF::Class::Type where { .<Type> ~~ 'Pages' }; # autoloaded PDF::Pages
    method Pages returns Pages handles <page pages add-page delete-page insert-page page-count page-index media-box crop-box bleed-box trim-box art-box core-font use-font> { self.Root.Pages }

}
