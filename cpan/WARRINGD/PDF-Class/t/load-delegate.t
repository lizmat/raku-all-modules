use v6;
use Test;
plan 17;

use PDF::Class;
use PDF::COS::Name;

isa-ok PDF::Class.loader.load-delegate( :dict{ :Type<Page> }), (require ::('PDF::Page')), 'delegation sanity';
isa-ok PDF::Class.loader.load-delegate( :dict{ :Type<XObject>, :Subtype<Image> }), (require ::('PDF::XObject::Image')), 'delegation to subclass';
my $shading-class = PDF::Class.loader.load-delegate( :dict{ :ShadingType(2) });
isa-ok $shading-class, (require ::('PDF::Shading::Axial')), 'delegation by ShadingType';
isa-ok $shading-class, (require ::('PDF::COS::Dict')), 'delegation by ShadingType';

$shading-class = PDF::Class.loader.load-delegate( :dict{ :ShadingType(7) });
isa-ok $shading-class, (require ::('PDF::Shading::Tensor')), 'delegation by ShadingType';
isa-ok $shading-class, (require ::('PDF::COS::Stream')), 'delegation by ShadingType';

does-ok PDF::Class.loader.load-delegate( :dict{ :ShadingType(42) }), (require ::('PDF::Shading')), 'delegation by ShadingType (unknown)';
isa-ok PDF::Class.loader.load-delegate( :dict{ :Type<Unknown> }, :base-class(Hash)), Hash, 'delegation base-class';
isa-ok PDF::Class.loader.load-delegate( :dict{ :FunctionType(3) }, :base-class(Hash)), ::('PDF::Function::Stitching'), 'delegation by FunctionType';

does-ok PDF::Class.loader.load-delegate( :dict{ :Subtype<Link> }, :base-class(Hash)),  (require ::('PDF::Annot::Link')), 'annot defaulted /Type - implemented';
does-ok PDF::Class.loader.load-delegate( :dict{ :Subtype<Caret> }, :base-class(Hash)),  (require ::('PDF::Annot')), 'annot defaulted /Type - unimplemented';
does-ok PDF::Class.loader.load-delegate( :dict{ :S<GTS_PDFX> }, :base-class(Hash)),  (require ::('PDF::OutputIntent')), 'output intent defaulted /Type';

require ::('PDF::Pages');
my $pages = ::('PDF::Pages').new;
is $pages.Type, 'Pages', '$.Type init';

require ::('PDF::XObject::Form');
my PDF::COS::Name $Subtype .= coerce: :name<Form>;
my $form = ::('PDF::XObject::Form').new( :dict{ :BBox[0, 0, 100, 140 ], :$Subtype });
is $form.Subtype, 'Form', '$.Subtype init';

require ::('PDF::Shading::Radial');
my $shading = ::('PDF::Shading::Radial').new( :dict{ :ColorSpace(:name<DeviceRGB>),
								:Function(:ind-ref[15, 0]),
								:Coords[ 0.0, 0.0, 0.096, 0.0, 0.0, 1.0, 0],
							 } );
is $shading.ShadingType, 3, '$.ShadingType init';

require PDF::Function::PostScript;
my $function;
lives-ok { $function = PDF::Function::PostScript.new( :dict{ :Domain[-1, 1, -1, 1] } )}, "PostScript require";
lives-ok {$function.FunctionType}, 'FunctionType accessor';
