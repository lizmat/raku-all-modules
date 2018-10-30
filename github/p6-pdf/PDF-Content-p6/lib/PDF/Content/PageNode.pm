use v6;

use PDF::COS::Tie::Hash;

role PDF::Content::PageNode {

    #| source: http://www.gnu.org/software/gv/
    my subset Box of List where {.elems == 4}

    #| e.g. $.to-landscape(PagesSizes::A4)
    method to-landscape(Box $p --> Box) {
	[ $p[1], $p[0], $p[3], $p[2] ]
    }

    my constant %BBoxEntry = %(
	:media<MediaBox>, :crop<CropBox>, :bleed<BleedBox>, :trim<TrimBox>, :art<ArtBox>
    );
    my subset BoxName of Str where %%BBoxEntry{$_}:exists;

    method !get-prop(BoxName $box) is rw {
	my $bbox = %BBoxEntry{$box};
        self."$bbox"();
    }

    method bbox(BoxName $box-name) is rw {
        my &fetch-sub := do given $box-name {
            when 'media' { sub ($) { self.MediaBox // [0, 0, 612, 792] } }
            when 'crop'  { sub ($) { self.CropBox // self.bbox('media') } }
            default      { sub ($) { self!get-prop($box-name) // self.bbox('crop') } }
        };

        Proxy.new(
            FETCH => &fetch-sub,
            STORE => sub ($, Box $rect) {
                self!get-prop($box-name) = $rect;
            },
           );
    }

    method media-box(|c) is rw { self.bbox('media', |c) }
    method crop-box(|c)  is rw { self.bbox('crop',  |c) }
    method bleed-box(|c) is rw { self.bbox('bleed', |c) }
    method trim-box(|c)  is rw { self.bbox('trim',  |c) }
    method art-box(|c)   is rw { self.bbox('art',   |c) }

    method width  { .[2] - .[0] given self.media-box }
    method height { .[3] - .[1] given self.media-box }

}
