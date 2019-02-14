use v6;

use XML;

=begin LICENSE

Copyright (c) 2014, carlin <cb@viennan.net>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

=end LICENSE

role Printing::Jdf::Pool {
    has XML::Element $.Pool;

    method new(XML::Element $Pool) {
        self.bless(:$Pool);
    }
}

class Printing::Jdf::AuditPool is Printing::Jdf::Pool {
    has %!created;

    method Created( --> Hash ) {
        %!created ||= do {
            my XML::Element $c = Printing::Jdf::get($.Pool, "Created");
            %(
                AgentName => $c<AgentName>,
                AgentVersion => $c<AgentVersion>,
                TimeStamp => DateTime.new($c<TimeStamp>)
            );
        }
    }
}

class Printing::Jdf::ResourcePool is Printing::Jdf::Pool {
    has @!colorantOrder;
    has %!layout;
    has @!runlist;

    method ColorantOrder( --> List ) {
        @!colorantOrder ||= do {
            my XML::Element $co = Printing::Jdf::get($.Pool, <ColorantOrder>, Recurse => 1);
            my XML::Element @ss = Printing::Jdf::get($co, <SeparationSpec>, Single => False);
            @ss.map(*<Name>);
        }
    }

    method Layout( --> Hash ) {
        %!layout ||= do {
            my XML::Element $layout = Printing::Jdf::get($.Pool, <Layout>);
            my Str @pa = $layout<SSi:JobPageAdjustments>.split(' ');
            my XML::Element @sigs = Printing::Jdf::get($layout, <Signature>, Single => False);
            my %layout =
                Bleed => Printing::Jdf::mm($layout<SSi:JobDefaultBleedMargin>),
                PageAdjustments => {
                    Odd => { X => Printing::Jdf::mm(@pa[0]), Y => Printing::Jdf::mm(@pa[1]) },
                    Even => { X => Printing::Jdf::mm(@pa[2]), Y => Printing::Jdf::mm(@pa[3]) }
                },
                Signatures => parseSignatures(@sigs)
            ;
            %layout;
        }
    }

    method Runlist( --> Array ) {
        @!runlist ||=  do {
            my XML::Element $runlist = Printing::Jdf::get($.Pool, <RunList>);
            my XML::Element @runlists = Printing::Jdf::get($runlist, <RunList>, Single => False);
            my @files;
            for @runlists -> $root {
                my XML::Element $layout = Printing::Jdf::get($root, <LayoutElement>);
                my XML::Element $pagecell = Printing::Jdf::get($root, <SSi:PageCell>);
               my XML::Element $filespec;
               if not $layout<IsBlank> {
                   $filespec = Printing::Jdf::get($layout, <FileSpec>);
                }
                else {
                    $filespec = XML::Element.new(name => 'FileSpec', 
                        attribs => { URL => 'Blank Page' });
                }

                @files.push: ({
                    Run => $root<Run>,
                    Page => $root<Run> + 1,
                    Url => IO::Path.new($filespec<URL>),
                    CenterOffset => parseOffset($pagecell<SSi:RunListCenterOffset>),
                    Centered =>
                        $pagecell<SSi:RunListCentered> == 0 ?? False !! True,
                    Offsets => parseOffset($pagecell<SSi:RunListOffsets>),
                    Scaling => parseScaling($pagecell<SSi:RunListScaling>),
                    IsBlank => $layout.attribs<IsBlank>:exists
                });
            }
            @files;
        }
    }

    sub parseSignatures(@signatures --> Array ) {
        my Hash @s;
        for @signatures {
            my $eit = Printing::Jdf::get($_, <SSi:ExternalImpositionTemplate>);
            my $fs = Printing::Jdf::get($eit, <FileSpec>);
            my %sig =
                Name => $_<Name>,
                PressRun => $_<SSi:PressRunNo>.Int,
                Template => IO::Path.new($fs<URL>)
            ;
            @s.push: ({%sig});
        }
        @s;
    }

    our sub parseOffset($offset --> Hash ) {
        my Str @sets = $offset.split(' ');
        @sets = ('0', '0') if $offset eq "0";
        { X => Printing::Jdf::mm(@sets[0]), Y => Printing::Jdf::mm(@sets[1]) };
    }

    our sub parseScaling($scaling --> Hash ) {
        my Str @sc = $scaling.split(' ');
        { X => @sc[0]*100, Y => @sc[1]*100 };
    }
}

class Printing::Jdf {
    has XML::Document $.jdf;
    has Printing::Jdf::AuditPool $.AuditPool;
    has Printing::Jdf::ResourcePool $.ResourcePool;

    method new(Str $jdf-xml --> Printing::Jdf ) {
        my XML::Document $jdf = from-xml($jdf-xml);
        my Printing::Jdf::AuditPool $AuditPool .= new(getPool($jdf, "AuditPool"));
        my Printing::Jdf::ResourcePool $ResourcePool .= new(getPool($jdf, "ResourcePool"));
        self.bless(:$jdf, :$AuditPool, :$ResourcePool);
    }

    our sub get(XML::Element $xml, Str $TAG, Bool :$Single = True,Int :$Recurse = 0) {
        $xml.elements(:$TAG, SINGLE => $Single, RECURSE => $Recurse);
    }

    sub getPool(XML::Document $xml, Str $name --> XML::Element ) {
        $xml.elements(TAG => $name, :SINGLE);
    }

    our proto mm($pts --> Int ) { * }

    our multi sub mm(Str $pts --> Int ) {
        mm($pts.Rat);
    }

    our multi sub mm(Int $pts --> Int ) {
        mm($pts.Rat);
    }

    our multi sub mm(Rat $pts --> Int ) {
        my Rat constant $inch = 25.4;
        my Rat constant $mm = $inch / 72;
        ($mm * $pts).round;
    }
}

# vim: ft=perl6 ts=4
