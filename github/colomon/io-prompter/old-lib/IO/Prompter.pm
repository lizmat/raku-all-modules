use v6;
# [TODO: Currently only runs until Rakudo 2010/01 release]

module IO::Prompter;

# Utility regexes...
my regex null    { <before .?> }   # [TODO: Remove when Rakudo implements this]
my regex sign    { <[+\-]>     }
my regex digits  {  \d+:       }
my regex number  { <&sign>? <&digits> [\.<&digits>?]? [<[eE]><&sign>?<&digits>]? }
my regex integer { <&sign>? <&digits>        }
my regex yes     { :i ^ \h* [ y | yes ]    }
my regex Yes     { :i <-[y]>               }
my regex yesno   { :i [ y | yes | n | no ] }
my regex YesNo   {    [ Y | Yes | N | No ] }

# Table of information for building prompters for various types...
my %constraint =
#    Prompter   Add to  What to print on  Use this to check that    Conversion
#      type     prompt  invalid input     input is valid            function
#    ========   ======  ================  ======================    ==========
      ::Int  => [': ', 'a valid integer', /^ \h* <&integer> \h* $/, *.Int        ],
      ::Real => [': ', 'a valid number',  /^ \h* <&number>  \h* $/, *.Real       ],
      ::Bool => ['? ', '"yes" or "no"',   /^ \h* <&yesno>   \h* $/, {?m/<&yes>/} ],
    SemiBool => ['? ', '"yes" or "no"',   /^ \h* \S+        \h* $/, {?m/<&yes>/} ],
 CapSemiBool => ['? ', '"Yes" for yes',   /^ \h* <&Yes>     \h* $/, {?m/<&yes>/} ],
 CapFullBool => ['? ', '"Yes" or "No"',   /^ \h* <&YesNo>   \h* $/, {?m/<&yes>/} ],
         Any => [': ', 'anything',        -> $a { Bool::True },     { $^self }   ];

# This sub ensures a value matches the specified set of constraints...
sub invalid_input ($input, @constraints) {
    for @constraints -> $constraint {
        # say "Processing " ~ :$constraint.perl;
        if $input !~~ $constraint.value {
            return "(must {$constraint.key})";
        }
    }
    return;
}

my $NULL_DEFAULT = Any;

# This sub takes type info and provides a prompter that accepts only that type
# [TODO: Prompters are stateless, so this sub should be 'is cached'
#        when that's available]...
sub build_prompter_for (Mu $type, :$in = $*IN, :$out = $*OUT, *%build_opt) {

    # Grab the correct info out of the table...
    my ($punct, $description, $match, $extractor)
        = (%constraint{$type} // %constraint<Any>).list;

    # Create single hash of input constraints...
    my @input_constraints = 
        "be $description" => $match,
        # [TODO: The next key should be something like: 
        #        "be %build_opt<type_constraints>.perl()"
        #        if that ever returns something useful   ]
        "be an acceptable value" => %build_opt<type_constraints>.defined
            ?? { $extractor($^input) ~~ %build_opt<type_constraints> } !! { 1 },
        %build_opt<must>.pairs;
    
    # Check that default supplied (via lower case option) is a valid response...
    if %build_opt<default>.defined {
        if invalid_input(%build_opt<default>, @input_constraints) -> $problem {
            warn "prompt(): Cannot use default value {%build_opt<default>.perl} ",
                $problem;
            %build_opt.delete('default');
        }
    }
    
    # Use it to build the requested prompter...
    return sub ($prompt is copy, *%opt) {
        # Add trailing punctuation, if requested to:
        $prompt ~= $punct if %build_opt<autopunctuate>;

        # Print the prompt if I/O is interactive...
        $out.print($prompt) if ($in & $out).t;

        # Prompt until we get something acceptable (or EOF)...
        loop {
            # Get what they typed and give up if it as EOF...
            my $input = $in.get() // return;

            # Insert the (post-checked) DEFAULT if they just hit <ENTER>...
            $input = %build_opt<DEFAULT> // $input if $input eq "";

            # Convert the input to the eventual return value...
            my $retval = $extractor($input);

            # Check if input satisified all constraints; if not, reprompt...
            if invalid_input($input, @input_constraints) -> $problem {
                $out.print("$prompt$problem ") if ($in & $out).t;
            }
            # Successfully read in an acceptable value, so return it...
            else {
                return $retval;
            }
        }
    }
}

# Given a varname, convert it to a pretty prompt string...
sub varname_to_prompt ($name) {
    return $name.subst(/^<-alnum>+/, "").subst(/_/, " ", :g).ucfirst;
}

# This variant takes a block and loops, prompting for the block's parameters
# then passing the values to the block until a prompt EOF's...
multi sub prompt ( &block ) is export {
    # These will eventually hold the arguments to be passed to the block...
    my (%named, @positional);

    # Flag to watch for EOF's in the middle of a prompt sequence...
    my $eof;

    # Build the necessary prompters for the block's parameters...
    my @param_prompters = gather for &block.signature.params -> $param {

        # Does this parameter have extra 'where'ish constraints?
        my $type_constraints = $param.constraints;

        # Build the appropriate prompter for this parameter...
        my $prompter = build_prompter_for(
                            $param.type, :$type_constraints, :autopunctuate,
                            :default($NULL_DEFAULT), :must({})
                       );

        # Build a closure that uses the prompter and saves the resulting value 
        # to the appropriate positional or named argument set...
        if $param.named {
            # Convert the named parameter's key to a nice promt string...
            my $label = $param.named_names;
            my $name  = varname_to_prompt($label);

            # Build the closure that prompts for the arg value and saves it
            # [TODO: the lexical is only there to stop 2010/01 Rakudo barfing]
            take my $handler
                = { %named.push($label => $prompter($name) // $eof++) };
        }
        else {
            # Convert the positional parameter's name to a nice prompt string...
            my $name = varname_to_prompt($param.name);

            # Build the closure that prompts for the arg value and saves it
            # [TODO: the lexical is only there to stop 2010/01 Rakudo barfing]
            take my $handler = { @positional.push($prompter($name) // $eof++) };
        }
    }

    # Implement the prompt-and-execute-block loops...
    gather loop {
        # Clear your throat...
        say "";

        # Reset the block's arguments sets...
        %named = @positional = ();

        # Run the prompters to fill the argument sets...
        for @param_prompters { $^prompter() unless $eof }

        # Give up if the user EOF'd any of the input requests...
        last if $eof;

        # Otherwise, execute the block, passing the needed arguments...
        block(|@positional, |%named);
    }
}

my $DEFAULT_PROMPT = '>';
my $ARGS_PROMPT = 'Enter command-line args:';
my $ENV_VARS = join "", map {"my \$$^NAME = %*ENV<$^NAME>;"}, %*ENV.keys;

my $wiped;

# This variant does the usual "single input" prompt-and-read behaviour
# [TODO: Should provide short-forms too: :a(:argv) when Rakudo supports that]...
multi sub prompt-conway (
  :$args        of Bool,
  :$default     of Str        = $NULL_DEFAULT,
  :$DEFAULT     of Str        = $default,
  :$fail        of Bool       = sub{False},

  # [TODO: needs Term::ReadKey]
  # :$guarantee   of Hash       = /<null>/,

  :$in          of IO         = $*IN,
  :$integer     of Bool,

  # [TODO: needs Term::ReadKey ]
  # :$keyletters  of Bool,

  :$must        of Hash       = hash{},
  :$number      of Bool,
  :$out         of IO         = $*OUT,
  :$prompt      of Str is copy,
  :$wipe        of Bool,
  :$wipefirst   of Bool,
  :$yes         of Bool,
  :$yesno       of Bool,
  :$Yes         of Bool,
  :$YesNo       of Bool,
  *@prompt,
) is export(:DEFAULT) {
    # If prompt not explicitly specified, use the strings provided, or else
    # use a default prompt...
    $prompt //= @prompt ?? @prompt.join
            !!  $args   ?? $ARGS_PROMPT
            !!             $DEFAULT_PROMPT;

    # Clean up the prompt, adding trailing punctuation, as required...
    $prompt ~= ": " if $prompt ~~ /\w $/;
    $prompt ~= " "  if $prompt ~~ /\S $/;
    $prompt.=subst(/\n$/,"");

    # Determine the type of prompter to build
    # [TODO: I really wish there were a cleaner way to do this!]...
    my $prompter_type =  $Yes      ??  'CapSemiBool'
                     !!  $YesNo    ??  'CapFullBool'
                     !!  $yes      ??  'SemiBool'
                     !!  $yesno    ??  Bool
                     !!  $integer  ??  Int
                     !!  $number   ??  Real
                     !!                'Any';

    # Get the necessary prompter...
    my $prompter = build_prompter_for($prompter_type, :$in, :$out,
                                      :$must, :$default, :$DEFAULT
                                     );

    # Wipe first if necessary...
    print "\n" x 1000 if $wipe || ($wipefirst && !$wiped++);

    # Use the necessary prompter...
    my $input = $prompter($prompt, :$yes, :$Yes, :$yesno, :$YesNo);

    if $args {
        # [TODO: Should be: glob eval "$ENV_VARS; << $input >>" ]
        @*ARGS = eval "$ENV_VARS; << $input >>";
        return 1;
    }
    
    # Determine the success of the request...
    my $failed = !$input.defined
              || $yes|$Yes|$yesno|$YesNo && !$input
              || $input ~~ $fail;
              
    # [NOTE: conscious decision not to offer :verbatim option
    #        (i.e. string-only return) because strings are objects too
    if $failed {
        return $input but Bool::False;
    } else {
        return $input but Bool::True;
    }
}

# [TODO: Port docs from Perl 5 IO::Prompter module]
#
# [TODO: Implement scripted input from =begin PROMPTS/=end PROMPTS block
#        when Term::ReadKey available and $=POD works ]
