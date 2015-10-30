use XML;

unit module XML::Canonical;

our proto canonical(|) is export { * };

multi sub canonical(Str $xml, :$subset, :$exclusive, :@namespaces) {
    return canonical(from-xml($xml).root, :$subset, :$exclusive, :@namespaces);
}

multi sub canonical(XML::Document $xml, :$subset, :$exclusive, :@namespaces) {
    return canonical($xml.root, :$subset, :$exclusive, :@namespaces);
}

multi sub canonical(XML::Text $xml, *%) {
    my $text = $xml.text;

    # normalize line endings
    $text ~~ s:g/\n/\n/;

    # un-escape everything
    $text ~~ s:g/\&(\S+?)\;/{
        my $e = $0.Str.lc;

        if    $e eq 'amp'          { '&' }
        elsif $e eq 'apos'         { "'" }
        elsif $e eq 'lt'           { '<' }
        elsif $e eq 'gt'           { '>' }
        elsif $e eq 'quot'         { '"' }
        elsif $e ~~ /^<[0..9]>+$/  { chr($e) }
        elsif $e ~~ /^x<[0..9]>+$/ { chr(:16($e.substr(1))) }

        else { die "Unknown XML entity: "~$e }
    }/;

    # escape < > &
    $text ~~ s/\&/&amp;/;
    $text ~~ s/\</&lt;/;
    $text ~~ s/\>/&gt;/;

    return $text;
}

multi sub canonical(XML::CDATA $xml, *%) {
    my $text = $xml.data;

    # escape < > &
    $text ~~ s/\&/&amp;/;
    $text ~~ s/\</&lt;/;
    $text ~~ s/\>/&gt;/;

    return $text;
}

multi sub canonical(XML::Element $xml, :$subset is copy, :$exclusive, :$namespaces, :%exc-rendered-ns is copy) {
    my @namespaces = @$namespaces;
    %exc-rendered-ns{'#default'} = '' unless %exc-rendered-ns;

    my %extra-attribs;
    if $subset {
        my @parts = $subset.split(/\//).grep({$_});
        die "Invalid subset" if @parts[0] ne $xml.name;
        @parts.shift;
        while @parts {
            for $xml.attribs.kv -> $k, $v {
                if $k ~~ /^xmlns(.*)?/ {
                    my $part = $0.Str;
                    $part ~~ s/\:// if $part;
                    if !$exclusive || @namespaces.grep({ $part ?? $_ eq $part !! $_ eq '#default' }) {
                        %extra-attribs{$k} = $v;
                        %exc-rendered-ns{$k} = $v;
                    }
                }
            }
            my $tmp = $xml.elements(:TAG(@parts[0]), :SINGLE);
            die "Invalid subset" unless $tmp;
            $xml := $tmp;
            @parts.shift;
        }
    }

    my $element = '<' ~ $xml.name;
    my @keys = $xml.attribs.keys;

    @keys .= grep(&_needed_attribute.assuming($xml));

    if $exclusive {
        # special namespace rules, so strip out all xmlns attributes
        # (inclusivenamespaces rule handled with extra-attribs below)
        @keys .= grep({ !( $_ ~~ /^xmlns/ ) });

        my %used_ns;
        for @keys {
            my @s = .split(/\:/);
            if @s.elems > 1 {
                %used_ns{@s[0]}++;
            }
        }
        my @s = $xml.name.split(/\:/);
        if @s.elems > 1 {
            %used_ns{@s[0]}++;
        }
        else {
            %used_ns{'#default'}++;
        }

        for %used_ns.keys {
            if !(%exc-rendered-ns{$_}:exists) || %exc-rendered-ns{$_} ne ($_ eq '#default' ?? $xml.nsURI('') !! $xml.nsURI($_)) {
                if $_ eq '#default' {
                    %extra-attribs{'xmlns'} = $xml.nsURI('');
                    %exc-rendered-ns{'#default'} = $xml.nsURI('');
                }
                else {
                    %extra-attribs{'xmlns:' ~ $_} = $xml.nsURI($_);
                    %exc-rendered-ns{$_} = $xml.nsURI($_);
                }
            }
        }
    }

    @keys.append(%extra-attribs.keys);

    @keys .= sort(&_sort_attributes.assuming($xml));

    for @keys -> $k {
        my $v = %extra-attribs{$k};
        $v //= $xml.attribs{$k};

        # escape " < > &
        $v ~~ s/\&/&amp;/;
        $v ~~ s/\"/&quot;/;
        $v ~~ s/\</&lt;/;
        $v ~~ s/\>/&gt;/;

        $element ~= " $k=\"$v\"";
    }
    $element ~= '>';

    for $xml.nodes {
        $element ~= canonical($_, :$exclusive, :@namespaces, :%exc-rendered-ns);
    }

    $element ~= '</' ~ $xml.name ~ '>';

    return $element;
}

sub _needed_attribute($xml, $key) {
    return True unless $key ~~ /^xmlns/;

    if $xml.parent ~~ XML::Document {
        return True if $xml.attribs{$key};
        return False;
    }
    else {
        my $value = $xml.attribs{$key};
        my @keyparts = $key.split(/\:/);
        @keyparts[1] ||= '';

        return False if ($xml.parent.nsURI(@keyparts[1]) eq $value);
        return True;
    }
}

sub _sort_attributes($xml, $a, $b) {
    # namespaces go first
    if _is_xmlns($a) && !_is_xmlns($b) {
        Less;
    }
    elsif _is_xmlns($b) && !_is_xmlns($a) {
        More;
    }
    # namespaces ordered simply
    elsif _is_xmlns($a) && _is_xmlns($b) {
        $a cmp $b;
    }
    # attributes ordered by namespace, then name
    # if no namespace, treat the namespace as "" (empty string)
    else {
        my @aparts = $a.split(/\:/);
        if @aparts[1] {
            @aparts[0] = $xml.nsURI(@aparts[0]);
        }
        else {
            @aparts[1] = @aparts[0];
            @aparts[0] = '';
        }

        my @bparts = $b.split(/\:/);
        if @bparts[1] {
            @bparts[0] = $xml.nsURI(@bparts[0]);
        }
        else {
            @bparts[1] = @bparts[0];
            @bparts[0] = '';
        }

        my $p0 = @aparts[0] cmp @bparts[0];
        if $p0 ne Same {
            $p0;
        }
        else {
            @aparts[1] cmp @bparts[1];
        }
    }
}

sub _is_xmlns($a) {
    return True if ($a eq 'xmlns' || $a ~~ /^xmlns\:/);
    False;
}
