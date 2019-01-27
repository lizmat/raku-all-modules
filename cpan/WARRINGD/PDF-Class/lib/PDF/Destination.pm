use v6;
use PDF::COS::Tie;
use PDF::COS::Tie::Array;

my subset NumNull where { ($_ // Numeric) ~~ Numeric };  #| UInt value or null

role PDF::Destination
    does PDF::COS::Tie::Array {

    my enum Fit is export(:Fit) «
        :FitXYZoom<XYZ>     :FitWindow<Fit>
        :FitHoriz<FitH>     :FitVert<FitV>
        :FitRect<FitR>      :FitBox<FitB>
        :FitBoxHoriz<FitBH> :FitBoxVert<FitBV>
        »;

    use PDF::Page;
    use PDF::COS::Name;

    my subset PageRef where PDF::Page|UInt|Pair;
    method is-page-ref { self.[0] ~~ PDF::Page }
    has PageRef $.page is index(0);
    has PDF::COS::Name $.fit is index(1);
    # See [PDF 3200 Table 151 - Destination syntax]
    multi sub is-dest-like(PageRef $page, 'XYZ', NumNull $left?,
                           NumNull $top?, NumNull $zoom?)          { True }
    multi sub is-dest-like(PageRef $page,)                         { True }
    multi sub is-dest-like(PageRef $page, 'Fit')                   { True }
    multi sub is-dest-like(PageRef $page, 'FitH', NumNull $top?)   { True }
    multi sub is-dest-like(PageRef $page, 'FitV', NumNull $left?)  { True }
    multi sub is-dest-like(PageRef $page, 'FitR', Numeric $left,
                           Numeric $bottom, Numeric $right,
                           Numeric $top )                          { True }
    multi sub is-dest-like(PageRef $page, 'FitB')                  { True }
    multi sub is-dest-like(PageRef $page, 'FitBH', NumNull $top?)  { True }
    multi sub is-dest-like(PageRef $page, 'FitBV', NumNull $left?) { True }
    multi sub is-dest-like(|c) is default                          { False }

    my subset DestinationLike of List is export(:DestinationLike) where is-dest-like(|$_);

    method delegate-destination(DestinationLike $_) {
        PDF::Destination[ .[1] ];
    }

    method !dest(List $dest) { PDF::COS.coerce( $dest, $.delegate-destination($dest) ) }

    #| constructs a new PDF::Destination array object
    sub fit(Fit $f) { $f.value }
    multi method construct(FitWindow,  PageRef :$page!, )                { self!dest: [$page, fit(FitWindow), ] }
    multi method construct(FitHoriz,   PageRef :$page!, Numeric :$top )  { self!dest: [$page, fit(FitHoriz),    $top ] }
    multi method construct(FitVert,    PageRef :$page!, Numeric :$left ) { self!dest: [$page, fit(FitVert),     $left ] }
    multi method construct(FitBox,     PageRef :$page!, )                { self!dest: [$page, fit(FitBox),      ] }
    multi method construct(FitBoxHoriz,PageRef :$page!, Numeric :$top )  { self!dest: [$page, fit(FitBoxHoriz), $top] }
    multi method construct(FitBoxVert, PageRef :$page!, Numeric :$left ) { self!dest: [$page, fit(FitBoxVert),  $left] }

    multi method construct(FitXYZoom,  PageRef :$page!, Numeric :$left,
                           Numeric :$top, Numeric :$zoom )       { self!dest: [$page, fit(FitXYZoom), $left, $top, $zoom ] }

    multi method construct(FitRect,    PageRef :$page!,
                           Numeric :$left!,   Numeric :$bottom!,
                           Numeric :$right!,  Numeric :$top!, )  { self!dest: [$page, fit(FitRect),   $left,
                                                                                                      $bottom, $right, $top] }

    multi method construct(PageRef :$page!, )                    { self!dest: [$page, fit(FitWindow), ] }
    multi method construct(DestinationLike $dest) { self.construct(|$dest) }
    multi method construct(*@args) is default {
        fail "unable to construct destination: {@args.perl}";
    }

    # Coercions for explicit and named destinations
    # a named destination may be either a byte-string or name object
    my subset DestSpec is export(:DestSpec) where PDF::Destination|Str;
    my subset DestPageRefLike of DestinationLike where .[0] ~~ PDF::Page;
    proto sub coerce-dest($,$) is export(:coerce-dest) {*};
    multi sub coerce-dest(DestPageRefLike $_, DestSpec) {
        PDF::COS.coerce( $_, $?ROLE.delegate-destination($_) );
    }

    my subset DestSpecRemote is export(:DestSpecRemote) where PDF::Destination|Str;
    my subset DestPageNumLike of DestinationLike where .[0] ~~ UInt;
    multi sub coerce-dest(DestPageNumLike $_, DestSpecRemote) {
        PDF::COS.coerce( $_, $?ROLE.delegate-destination($_) );
    }

    multi sub coerce-dest($_, $) is default {
        fail "Unable to handle destination: {.perl}";
    }

}

role PDF::Destination['XYZ']
    does PDF::Destination {
    has Numeric $.left is index(2);
    has Numeric $.top is index(3);
    has Numeric $.zoom is index(4);
}

role PDF::Destination['Fit']
    does PDF::Destination {
}

role PDF::Destination['FitH']
    does PDF::Destination {
    has Numeric $.top is index(2);
}

role PDF::Destination['FitV']
    does PDF::Destination {
    has Numeric $.left is index(2);
}

role PDF::Destination['FitR']
    does PDF::Destination {
    has Numeric $.left is index(2);
    has Numeric $.bottom is index(3);
    has Numeric $.right is index(4);
    has Numeric $.top is index(5);
}

role PDF::Destination['FitB']
    does PDF::Destination {
}

role PDF::Destination['FitBH']
    does PDF::Destination {
    has Numeric $.top is index(2);
}

role PDF::Destination['FitBV']
    does PDF::Destination {
    has Numeric $.left is index(2);
}


