use v6;

module Lingua::EN::Numbers::Ordinal;

sub ordinal(Int $input) is export {
    ##STEP 0: Preparation
    # NYI, but still a good guide to the below arrays
    #my enum NumType <base cardinal ordinal>;

    my $n = $input;

    # for the single digits
    my @single = ['zero','','th'],['','one','first'],['','two','second'],['th','ree','ird'],['four','','th'],['fi','ve','fth'],['six','', 'th'],['seven','','th'],['eight','','h'],['nin','e','th'];

    # for those pesky 10..19 numbers (seems almost every language does this.)
    my @teens = ['ten','','th'],['eleven','','th'],['twel','ve','fth'],['thirteen','','th'],['fourteen','','th'],['fifteen','','th'],['sixteen','','th'],['seventeen','','th'],['eighteen','','th'],['nineteen','','th'];

    # for the tens digit (bar that pesky one)
    my @tenplace = ['','',''],['','',''],['twent','y','ieth'],['thirt','y','ieth'],['fort','y','ieth'],['fift','y','ieth'],['sixt','y','ieth'],['sevent','y','ieth'],['eight','y','ieth'],['ninet','y','ieth'];

    # for the groups of three
    my @highdenoms = ['','',''],['thousand','','th'],['million','','th'],['billion','','th'],['trillion','','th'];

    # setting up for the main operation
    $n .= Str;
    $n = '0' ~ $n until $n.chars %% 3;
    my @number = $n.comb(/<digit>**3/);
    my @outnum;
    my $output;

    die 'Number too large for &ordinal. Try &ordinal_digit, it has no upper limit.' if @number.elems > @highdenoms.elems;

    if ($input != 0) { # if the input wasn't zero, let's go!
        # this for loop is where the magic happens!
        for @number.kv -> $index, $hundred {
            my $last = $index+1 == +@number;
            my $outtmp;

            ##STEP 1: Hundreds digit
            if $hundred.comb[0] !~~ 0 {
                $outtmp ~= @single[$hundred.comb[0]][0] ~ @single[$hundred.comb[0]][1] ~ " hundred";
                $outtmp ~= ($hundred.substr(1,2) ~~ 0 && $last ?? "th" !! " ");
            }

            ##STEP 2: Tens digit
            if $hundred.comb[1] ~~ 1 {
                $outtmp ~= @teens[$hundred.comb[2]][0];
                $outtmp ~= $last ?? @teens[$hundred.comb[2]][2] !! @teens[$hundred.comb[2]][1]; # unlike the hundreds digit above, it's useless to check for the rest of the number being 0 when it's in the teens (10..19).
            }
            else {
                $outtmp ~= @tenplace[$hundred.comb[1]][0];
                ##STEP 3: Ones digit
                if $hundred.comb[2] ~~ 0 {
                    $outtmp ~= $last ?? @tenplace[$hundred.comb[1]][2] !! @tenplace[$hundred.comb[1]][1];
                }
                else {
                    $outtmp ~= @tenplace[$hundred.comb[1]][1] ~ "-" if @tenplace[$hundred.comb[1]][1];
                    $outtmp ~= @single[$hundred.comb[2]][0];
                    $outtmp ~= $last ?? @single[$hundred.comb[2]][2] !! @single[$hundred.comb[2]][1];
                }
            }
            ##STEP 4: Spit out the newly generated group-of-three ordinal, then on to the next!
            @outnum.push($outtmp);
        }

        @outnum = @outnum».trim;

        ##STEP 5: Add groups of three delimiters
        for 1..@outnum.elems {
            if @outnum[*-$_] !~~ "" { # if the element is empty, don't bother. Otherwise, do this:
                @outnum[*-$_] ~= " " ~ @highdenoms[$_-1][0];
                @outnum[*-$_] ~= (@outnum[*-($_-1)..*-1].join("") ~~ "" ?? @highdenoms[$_-1][2] !! @highdenoms[$_-1][1]);
            }
        }
        ##STEP 6: Send the number to the user!
        # removing null elements. Should be using grep, but doesn't work.
        my @temp;
        for 0..^@outnum.elems {
            @temp.push(@outnum[$_]) if ?@outnum[$_];
        }
        @outnum = @temp;
        return @outnum.join(' ').trim; # sometimes trailing spaces get in. Hopefully a *real* fix will occur someday.
    }
    else { # if it does equal zero, then...
        return "zeroth"; # yes, this entry exists in the @single array, but it doesn't work. This does, though.
    }
}

sub ordinal_digit(Int $input) is export {

    # get the last two digits
    # The .fmt is to pad single digits to keep [*-2..*-1] from dying
    my @last_two_nums = $input.Str.fmt('%02d').comb[*-2..*-1]».Int;
    my $result = $input.Str;

    if @last_two_nums[0] == 1 { # is the last two digits in 10..19?
        $result ~= "th";
    }
    else {
        given @last_two_nums[1] {
            when 1 {
                $result ~= "st";
            }
            when 2 {
                $result ~= "nd";
            }
            when 3 {
                $result ~= "rd";
            }
            default {
                $result ~= "th";
            }
        }
    }

    return $result; # there, that wasn't nearly as hard as &ordinal, was it?
}
