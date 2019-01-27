use v6;
use CSS::Properties::Box :Edges;

class CSS::Properties::PageBox
    is CSS::Properties::Box {

    use CSS::Properties::Units :mm, :in, :pt, :ops;
    my enum PageSizes is export(:PageSizes) «
	    :A5(148mm, 210mm)
	    :A4(210mm, 297mm)
	    :A3(297mm, 420mm)
	    :B5(176mm, 250mm)
	    :B4(250mm, 353mm)
	    :JIS-B5(182mm, 257mm)
	    :JIS-B4(257mm, 364mm)
	    :LETTER(8.5in, 11in)
	    :LEGAL(8.5in, 14in)
	    :LEDGER(8.5in, 17in)
	»;

    method !padding-box($right, $bottom, $left, $top) {
        my @padding = self.measurements: $.css.padding;
        my @border  = self.measurements: $.css.border-width;
        my @margin  = self.measurements: $.css.margin;
        my @box = self.measurements: ($top, $left, $bottom, $right);
        for @padding, @border, @margin -> @b {
            @box[$_] -= @b[$_]
                for Top, Right;
            @box[$_] += @b[$_]
                for Bottom, Left;
        }
        @box;
    }

    method !page-rect(:$width = 595pt, :$height = 842pt) is export(:page-rect) {
        # todo: see https://www.w3.org/TR/css3-page/
        # @top-left-corner etc
        # page-break-before, page-break-after etc
        my @length;
        my $orientation = 'portrait';
        my Bool $auto = False;

        for $.css.size.list {
            when Numeric {
                @length.push: $_;
            }
            when 'portrait' | 'landscape' {
                $orientation = $_;
            }
            when 'auto' {
                $auto = True;
                @length = $width, $height;
            }
            when PageSizes.enums{.uc}:exists {
                @length = PageSizes.enums{.uc};
            }
            default {
                warn "unhandled body 'size' {.perl}";
            }
        }

        my ($page-width, $page-height) = do if @length {
            @length[1] //= @length[0];
            @length;
        } else {
            $auto = True;
            ($width, $height);
        }

        ($page-height, $page-width) = ($page-width, $page-height)
            if $orientation eq 'landscape' && !$auto;

        $_ = $.measure($_) for $page-width, $page-height;

        if $auto {
            # See [https://www.w3.org/TR/css-page-3/#variable-auto-sizing]
            with $.measure($.css.max-width) {
                $page-width = $_
                    if $page-width > $_;
            }
            with $.measure($.css.min-width) {
                $page-width = $_
                    if $page-width < $_;
            }
            with $.measure($.css.max-height) {
                $page-height = $_
                    if $page-height > $_;
            }
            with $.measure($.css.min-height) {
                $page-height = $_
                   if $page-height < $_;
            }
        }

        self!padding-box($page-width - $page-width,   # united zero
                         $page-height - $page-height, # united zero
                         $page-width, $page-height);
    }

    submethod TWEAK(|c) {
        self.Array = self!page-rect(|c);
    }

}
