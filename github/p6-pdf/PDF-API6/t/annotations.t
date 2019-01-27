use v6;
use Test;
plan 19;
use PDF::API6;
use PDF::Destination :Fit;
use PDF::Content::Color :ColorName;
use PDF::Page;
use PDF::XObject::Image;
use PDF::Action::GoToR;
use PDF::Annot::Text;
use PDF::Border :BorderStyle;

my PDF::API6 $pdf .= new;

$pdf.add-page for 1 .. 2;
my PDF::Page $page1 = $pdf.page(1);

sub dest(|c) { :destination($pdf.destination(|c)) }
sub action(|c) { :action($pdf.action(|c)) }

my $gfx = $pdf.page(1).gfx;

$gfx.Save;
$gfx.transform(:translate(5,10));

my $link;
$gfx.text: {
    .text-position = 377 -5 , 545 - 10;
    $link = $pdf.annotation(
        :text("See page 2"),
        :page(1),
        |dest(:page(2)),
        :color(Blue),
    );
}

ok  $page1.Annots[0] === $link, "annot added to source page";
ok $link.destination.page == $pdf.page(2), "annot reference to destination page";

my $image = PDF::XObject::Image.open: "t/images/lightbulb.gif";
my @image-region = $gfx.do($image, 350 - 5, 544 - 10);
my @rect = $gfx.base-coords: |@image-region;
lives-ok { $link = $pdf.annotation(
                 :page(1),
                 |dest(:page(2)),
                 :@rect,
                 :color(Blue),
             )}, 'construct link annot';

$gfx.Restore;

ok  $page1.Annots[1] === $link, "annot added to source page";
ok $link.destination.page == $pdf.page(2), "annot reference to destination page";

$gfx.text: {
    .text-position = 377, 515;
    lives-ok { $link = $pdf.annotation(
                     :page(1),
                     :text("Test link"),
                     |action(:uri<https://test.org>),
                     :color(Orange),
                 ); }, 'construct uri annot';

    ok  $page1.Annots[2] === $link, "annot added to source page";
    is $link.action.URI, 'https://test.org', "annot reference to URI";

    .text-position = 377, 485;
    lives-ok { $link = $pdf.annotation(
                     :page(1),
                     :text("Example PDF Form"),
                     |action(
                         :file<../t/pdf/OoPdfFormExample.pdf>,
                         :page(2), :fit(FitXYZoom), :top(400)
                     ),
                     :color(Green),
                 ); }, 'construct file annot';

    ok  $page1.Annots[3] === $link, "remote link added";
    my PDF::Action::GoToR $action = $link.action;
    is $action.file, '../t/pdf/OoPdfFormExample.pdf', 'Goto annonation file';
    is $action.destination.page, 2, 'Goto annonation page number';
    is $action.destination.fit, FitXYZoom, 'Goto annonation fit';

    my PDF::Annot::Text $note;
    my $content = "To be, or not to be: that is the question: Whether 'tis nobler in the mind to suffer the slings and arrows of outrageous fortune, or to take arms against a sea of troubles, and by opposing end them?";

    lives-ok { $note = $pdf.annotation(
                     :page(1),
                     :$content,
                     :rect[ 377, 465, 455, 477 ],
                     :color[0, 0, 1],
                     :Open,
                 ); }, 'construct text note annot';

    ok  $page1.Annots[4] === $note, "text annot added";
    is $note.content, $content, "Text note annotation";

    my $border-style = {
        :width(1),  # 1 point width
        # 3 point dashes, alternating with 2-point gaps
        :style(BorderStyle::Dashed),
        :dash-pattern[3, 2],
    };

    .text-position = 377, 425;
    lives-ok { $link = $pdf.annotation(
                     :page(1),
                     |action(:uri<https://test2.org>),
                     :text("Styled Border"),
                     :color[.7, .8, .9],
                     :$border-style,
    ); }, 'construct styled uri annot';
    is $link.border-style.style, BorderStyle::Dashed, "setting of dashed border";

    my $attachment = $pdf.attachment("t/images/lightbulb.gif");
    lives-ok { $link = $pdf.annotation(
                     :page(1),
                     :$attachment,
                     :text-label("Light Bulb"),
                     :content('An example attached image file'),
                     :icon-name<Paperclip>,
                     :rect[ 377, 395, 425, 412 ],
                 ); }, 'construct file attachment annot';

    };
$pdf.save-as: "tmp/annotations.pdf";
done-testing;
