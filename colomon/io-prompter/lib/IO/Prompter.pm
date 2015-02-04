#! /Users/damian/bin/rakudo*
use v6;

class IO::Prompter::Result {
    has $.input;
    has $.failed;

    method defined {   $.input.defined }
    method Bool    { ! $.failed        }
    method Str     { ~ $.input         }
    method Stringy { ~ $.input         }
    method Num     { + $.input         }
    method Numeric { + $.input         }
    method Int     {   $.input.Int     }
    method Integral{   $.input.Int     }
};

module IO::Prompter {

my $null    = regex { <before .?> }
my $sign    = regex { <[+\-]> }
my $digits  = regex {  \d+:   }
my $number  = regex { <$sign>? <$digits> [\.<$digits>?]? [<[eE]><$sign>?<$digits>]? }
my $integer = regex { <$sign>? <$digits> }
my $yes     = regex { :i ^ \h* [ y | yes ]    }
my $Yes     = regex {    <-[y]> .*            }
my $yesno   = regex { :i [ y | yes | n | no ] }
my $YesNo   = regex {    [ Y | Yes | N | No ] }

my %constraint =
        Int  => [': ', 'a valid integer', /^ \h* <$integer> \h* $/,    *.Int     ],
        Num  => [': ', 'a valid number',  /^ \h* <$number>  \h* $/,    *.Num     ],
        Bool => ['? ', '"yes" or "no"',   /^ \h* <$yesno>   \h* $/, {?m/<$yes>/} ],
    SemiBool => ['? ', '"yes" or "no"',   /^ \h* \S+        \h* $/, {?m/<$yes>/} ],
 CapSemiBool => ['? ', '"Yes" for yes',   /^ \h* <$Yes>     \h* $/, {?m/<$yes>/} ],
 CapFullBool => ['? ', '"Yes" or "No"',   /^ \h* <$YesNo>   \h* $/, {?m/<$yes>/} ],
          Mu => [': ', 'anything',        /      <$null>         /, {  $^self  } ];

sub build_prompter_for (Mu $type, :$in = $*IN, :$out = $*OUT, *%build_opt) {
    my ($punct, $description, $match, $extractor)
        = (%constraint{$type} // %constraint<Mu>)[];

    return sub ($prompt is copy, *%opt) {
        $prompt ~= $punct if %build_opt<autopunctuate>;
        $out.print($prompt) if ($in & $out).t;
        loop {
            my $input = $in.get() // return;
            $input = %build_opt<default> // $input if $input eq "";
            if $input !~~ $match {
                $out.print("Please enter $description. $prompt")
                    if ($in & $out).t;
                next;
            }

            my $retval = $extractor($input);
            if $retval !~~ %build_opt<constraints>.all {
                $out.print("Please enter a valid {lc $prompt}")
                    if ($in & $out).t;
            }
            elsif %build_opt<must> {
                return $retval
                    unless gather for %build_opt<must>.kv -> $msg, $constraint {
                        next if $input|$retval ~~ $constraint;
                        $out.print( $msg ~~ /^<upper>/ ?? $msg !! $prompt ~ "(must $msg) ")
                            if ($in & $out).t;
                        take 'failed';
                        last;
                    }
            }
            else {
                return $retval;
            }
        }
    }
}

sub varname_to_prompt ($name) {
    return $name.subst(/^<-alnum>+/, "").subst(/_/, " ", :g).tc;
}

sub prompt-block (&block, :$in = $*IN, :$out = $*OUT) {
    my (%named, @positional, $eof);

    my @param_prompters = gather for &block.signature.params -> $param {
        my $constraints = $param.constraints;
        my $prompter   = build_prompter_for($param.type.perl, :$in, :$out, :$constraints, :autopunctuate);

        if $param.named {
            my $label = $param.named_names;
            my $name  = varname_to_prompt($label);
            take my $handler = { %named.push($label => $prompter($name) // $eof++) };
        }
        else {
            my $name = varname_to_prompt($param.name);
            take my $handler = { @positional.push($prompter($name) // $eof++) };
        }
    }

    my @gathered;    # Workaround for broken optimization behaviour
    loop {
        $out.print("\n");
        %named = @positional = ();
        for @param_prompters { $^prompter() unless $eof }
        last if $eof;
        push @gathered, gather block(|@positional, |%named);
    }
    return @gathered;
}


my $first_wipe = 1;

sub prompt-straight (
  $prompt_str?,
# :a(  :$args       )  of Bool,
# :c(  :$complete   )  of Array|Hash|Str,
      :d(:$default) as Str = "",
#--> :D(:$DEFAULT)        of Str,
# :e(  :$echo      )   of Str,
      :f(:$fail)      = False,
IO    :$in            = $*IN,
# :g(  :$guarantee )   of Hash       = hash{},
# :h(  :$history   )   of Str,
Bool  :i(:$integer),
# :k(  :$keyletters )  of Bool,
# :l(  :$line       )  of Bool,
#-->   :$menu          of Any,
Hash   :$must          = hash(),
Bool   :n(:$number)    ,
IO     :$out           = $*OUT,
Str    :p(:$prompt)    is copy,
# :r(  :$return     )  of Str,
#      :$stdio         of Bool,
# :s(  :$single     )  of Bool,
# :t(  :$timeout    )  of Bool,
Bool   :v(:$verbatim)  ,
Bool   :w(:$wipe)      ,
Bool   :wf(:$wipefirst),
Bool   :y(:$yes)       ,
Bool   :yn(:$yesno)    ,
Bool   :Y(:$Yes)       ,
Bool   :YN(:$YesNo)    ,
  *%unexpected_options,
  *@prompt,
) {
    # Die horribly if unknown options are offered...
    if %unexpected_options {
        die %unexpected_options.map({"Unknown option in call to prompt(): $_.perl()"}).join("\n");
    }

    # Sort out the prompt...
    @prompt.unshift($prompt_str // ());
    $prompt //= (@prompt ?? @prompt.join !! '>');
    if $prompt ~~ / (.*\w) $ / { $prompt ~= ": " }
    if $prompt ~~ / (.*\S) $ / { $prompt ~= " "  }
    $prompt.=subst(/\n$/,"");

    my $constraint =  $Yes      ??  'CapSemiBool'
                  !!  $YesNo    ??  'CapFullBool'
                  !!  $yes      ??  'SemiBool'
                  !!  $yesno    ??  'Bool'
                  !!  $integer  ??  'Int'
                  !!  $number   ??  'Num'
                  !!                'Mu';

    my $prompter = build_prompter_for($constraint, :$in, :$out, :$default, :$must);

    if ($wipe || $wipefirst && $first_wipe) {
        $out.print("\n" x 61)
            if ($in & $out).t;
        $first_wipe = 0;
    }

    my $input  = $prompter($prompt, :$default, :$yes, :$Yes, :$yesno, :$YesNo);
    my $failed = !$input.defined
              || $yes|$Yes|$yesno|$YesNo && !$input
              || ?( $input ~~ $fail );

    return $verbatim ?? $input
                     !! IO::Prompter::Result.new(:$input, :$failed);
}

sub prompt (
    *@prompt,
    *%options
) is export {
    if @prompt == 1 && @prompt[0] ~~ Block {
        prompt-block(@prompt[0], |%options);
    } else {
        prompt-straight(|@prompt, |%options);
    }
}

}
