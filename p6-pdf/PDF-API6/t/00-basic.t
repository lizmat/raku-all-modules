use v6;
use Test;
plan 9;
use PDF::API6;

my PDF::API6 $pdf .= new;

is $pdf.version, v1.3, 'PDF default version';
lives-ok { $pdf.version = v1.5 }, 'set version';
is $pdf.version, v1.5, 'PDF updated version';

lives-ok { $pdf.info.Title = 'Test Title'; }, 'set info field';
is $pdf.info.Title, 'Test Title', 'get info field';

my $xml = q:to<EOT>;
    <?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?>
    <?adobe-xap-filters esc="CRLF"?>
    <x:xmpmeta
      xmlns:x='adobe:ns:meta/'
      x:xmptk='XMP toolkit 2.9.1-14, framework 1.6'>
        <rdf:RDF
          xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
          xmlns:iX='http://ns.adobe.com/iX/1.0/'>
            <rdf:Description
              rdf:about='uuid:b8659d3a-369e-11d9-b951-000393c97fd8'
              xmlns:pdf='http://ns.adobe.com/pdf/1.3/'
              pdf:Producer='Acrobat Distiller 6.0.1 for Macintosh'></rdf:Description>
            </rdf:Description>
        </rdf:RDF>
    </x:xmpmeta>
    <?xpacket end='w'?>
    EOT

lives-ok { $pdf.xmp-metadata = $xml}, 'set xmp metadata';
is $pdf.xmp-metadata, $xml, 'get xmp metadata';

my $page = $pdf.add-page;
dies-ok {$page.Rotate = 89}, 'invalid rotation';
lives-ok {$page.Rotate = 90}, '90 degree rotation';

$page.text: {
    .font = .core-font('Helvetica');
    .text-position = 10, 10;
    .say: "Rotated Text";
}

$pdf.save-as: "tmp/basic.pdf";
