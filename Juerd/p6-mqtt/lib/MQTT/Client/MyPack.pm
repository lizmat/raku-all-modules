unit module Client::MQTT::MyPack;

use experimental :pack;

my grammar template {
    token basic_unit { <[a..zA..Z]> [ \d+ | '*' ]? }
    token composed_unit { '(' <TOP> ')' }
    token prefixed_unit { <length=basic_unit> '/' <unit> }
    token unit { <prefixed_unit> | <composed_unit> | <basic_unit> }
    token TOP {
        <.ws>?
        <unit>+ %% <.ws>?
    }
}

sub mypack ($template, *@list is copy) is export {

    my sub count_subunits ($composed) {
        my $sum;
        for $composed<TOP><unit> -> $unit {
            if $unit<composed_unit> -> $subcomposed {
                $sum += count_subunits($subcomposed);
            } else {
                $sum++;
            }
        }
        return $sum;
    }

    my @new_template;
    my @new_list;
    for template.parse($template).<unit> -> $unit {
        if $unit<prefixed_unit> -> $p {
            my $subunits = 1;
            my $subtemplate = $p<unit>;
            if ($p<unit><composed_unit>) -> $composed {
                $subunits = count_subunits($composed);
                $subtemplate = ~$composed<TOP>;
            }

            my $packed = mypack($subtemplate, @list.splice(0, $subunits, []));

            if ($p<length> eq 'm') {
                # Special mqtt number encoding, only used for packet length.
                my $v = $packed.elems;
                my @o;
                my $d = 0;
                while ($d == 0 or $d +& 0x80) {
                    $d = $v % 128;
                    $v = floor($v / 128);
                    $d +|= 0x80 if $v;
                    @o.push($d);
                }
                @new_template.push("C" x @o);
                @new_list.push(|@o);
            } else {
                # Something else; pack can handle it
                @new_template.push($p<length>);
                @new_list.push($packed.elems);
            }

            @new_template.push("a*");
            @new_list.push($packed.unpack("a*"));  # srsly... :(
        } elsif $unit<composed_unit> -> $c {
            my $subunits = count_subunits($c);
            my @sublist = @list.splice(0, count_subunits($c), []);

            if $c<TOP><unit>.grep(-> $/ { $<prefixed_unit> }) {
                my $packed = mypack($c<TOP>, @sublist);
                @new_template.push("a*");
                @new_list.push($packed.unpack("a*"));
            } else {
                # No length prefixes. Let regular pack handle it.
                @new_template.push(~$c<TOP>);
                @new_list.push(@sublist);
            }
        } else {
            @new_template.push(~$unit);
            @new_list.push(@list.shift);
        }
    }

    return pack ~@new_template, @new_list;
}
