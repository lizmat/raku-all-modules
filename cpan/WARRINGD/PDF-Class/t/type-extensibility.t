use v6;
use Test;
use PDF::Class::Loader;

=begin pod

=head1 Doc Extensiblity Tests

** Experimental Feature **

These tests check for the ability for users to define and autoload Doc
extension classes

=cut

=end pod

plan 10;

use lib 't/lib';

class MyLoader is PDF::Class::Loader {
    method class-paths {
         <TestDoc PDF PDF::COS::Type>
    }
}

PDF::COS.loader = MyLoader;

use TestDoc::Catalog;

my TestDoc::Catalog $Catalog .= new( :dict{ :Type( :name<Catalog> ),
                                           :Version( :name<1.3>) ,
                                           :Pages{ :Type{ :name<Pages> },
                                                   :Kids[],
                                                   :Count(0),
                                                 },
					   :ViewerPreferences{ :HideToolbar(True) },
                                         },
                                   ) ;

isa-ok $Catalog, TestDoc::Catalog;
is $Catalog.Type, 'Catalog', '$Catalog.Type';
is $Catalog.Version, '1.3', '$Catalog.Version';

# view preferences is a role
my $viewer-preferences;
lives-ok {$viewer-preferences = $Catalog.ViewerPreferences}, '$Catalog.ViewerPreferences';
does-ok $viewer-preferences, (require ::('TestDoc::ViewerPreferences')), '$Catalog.ViewerPreferences';
ok { $viewer-preferences.HideToolBar }, '$Catalog.ViewerPreferences.HideToolBar';
is $viewer-preferences.some-custom-method, 'howdy', '$Catalog.ViewerPreferences.some-custom-method';

isa-ok try { $Catalog.Pages }, (require ::('TestDoc::Pages'));

# should autoload from t/Doc/Page.pm
my $page = try { $Catalog.Pages.add-page };

isa-ok $page, (require ::('TestDoc::Page'));

my $form = try { $page.to-xobject };
isa-ok $form, (require ::('PDF::XObject::Form')), 'unextended class';

