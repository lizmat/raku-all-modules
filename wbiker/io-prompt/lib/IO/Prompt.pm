use v6;
unit class IO::Prompt;

## Exported functional frontend
##
sub ask ( Str $message, $default?, :$type ) is export {
    return IO::Prompt.ask($message,$default,:$type);
}
## Argument list binding (S06) Not Implemented Yet:
#sub ask ( |$args ) is export {
#    return IO::Prompt.ask( |$args );
#}

sub asker ( Str $message, $default?, :$type ) is export {
    return IO::Prompt.new( :$message, :$default, :$type );
}


## Private state for object calls. Populated by constructor.
##
has $!default;
has $!message;
has $!type;


## Method frontend to lowlevel type-specific methods
##
method ask ( Str $message=$!message,
                 $default=$!default,
                   :$type=$!type ) {

    my $args = \($message,$default);

    my $r = do {
      given $type {
        when .isa(Bool) { self.ask_yn(  |$args ); }
        when .isa(Int)  { self.ask_int( |$args ); }
        when .isa(Num)  { self.ask_num( |$args ); }
        when .isa(Str)  { self.ask_str( |$args ); }
        default            {
          given $default     {
            when .isa(Bool) { self.ask_yn(  |$args ); }
            when .isa(Int)  { self.ask_int( |$args ); }
            when .isa(Num)  { self.ask_num( |$args ); }
            when .isa(Str)  { self.ask_str( |$args ); }
            default            { self.ask_str( |$args ); }
          } # given $default
        } # given $type default
      } # given $type
    };

    return $r;
}


## The low-level IO methods. Override for testing etc.
##
method _do_prompt ( Str $question? ) {
    return (defined $question) ?? prompt($question)
                             !! prompt('');
}

method _do_say ( Str $output ) returns Bool {
    say $output;
    return Bool::True;
    ## Return False, if there is no point to continue
}


## The strings and rules used in the low-level
## query methods. Override these class attributes
## for localization etc.
##
our $.lang_prompt_Yn        = 'Y/n';
our $.lang_prompt_yN        = 'y/N';
our $.lang_prompt_yn        = 'y/n';
our $.lang_prompt_yn_retry  = 'Please enter yes or no';
our     $.lang_prompt_match_y   = / ^^ <[yY]> /;
our     $.lang_prompt_match_n   = / ^^ <[nN]> /;
our $.lang_prompt_int       = 'Int';
our $.lang_prompt_int_retry = 'Please enter a valid integer';
our $.lang_prompt_rat       = 'Num';
our $.lang_prompt_rat_retry = 'Please enter a valid number';
our $.lang_prompt_str       = 'Str';
our $.lang_prompt_str_retry = 'Please enter a valid string';


## Object evaluation in various contexts (type coersion)
##
method true {
    say "true";
    return self.ask( $!message, $!default, :type($!type // Bool) );
}

method Int {
    say "Int";
    return self.ask( $!message, $!default, :type($!type // Int) );
}

method Numeric {
    say "Numeric";
    return self.ask( $!message, $!default, :type($!type // Num) );
}

method Str {
    say "Str";
    return self.ask( $!message, $!default, :type($!type // Str) );
}


## Boolean Yes/No 
##
method ask_yn (  Str $message=$!message,
                $default=$!default ) returns Bool {

    my Bool $result;
    my $prompt-type = "[$.lang_prompt_yn] ";
    if defined $default and $default {
        $prompt-type = "[$.lang_prompt_Yn] ";
    }
    elsif $default.isa(Bool::False) {
        $prompt-type = "[$.lang_prompt_yN] ";
    }

    my Str $prompt = "";
    $prompt = "$message " if $message;
    $prompt ~= $prompt-type;

    loop {
        my Str $response = self._do_prompt( $prompt );

        given $response {
            when $.lang_prompt_match_y { $result = Bool::True }
            when $.lang_prompt_match_n { $result = Bool::False }
            when ''                    { $result = $default // Nil }
            default                    { $result = Nil }
        }
        last if defined $result;
        last if not self._do_say( $.lang_prompt_yn_retry );
    }

    return $result;
}


## Only Integers
##
method ask_int ( Str $message=$!message,
                    $default=$!default ) returns Int {

    my Int $result;
    my Str $prompt = "{$message ?? "$message " !! ''}[{
                       $default // $.lang_prompt_int}] ";

    loop {
        my Str $response = self._do_prompt( $prompt );

        given $response {
            when /^^ \d+ $$/
                { $result = +$response }
            when ''
                { $result = $default // Nil }
            default
                { $result = Nil }
        }
        last if defined $result;
        last if not self._do_say( $.lang_prompt_int_retry );
    }
 
   return $result;
}


## Numeric type, can hold integers, numbers and eventually rationals
##
method ask_num ( Str $message=$!message,
                 $default=$!default ) returns Numeric {

    my Numeric $result;
    my Str $prompt = "{$message ?? "$message " !! ''}[{
                       $default // $.lang_prompt_rat}] ";

    loop {
        my $response = self._do_prompt( $prompt );

        my $possible_num = $response;
        # if the response is a Numeric, all's fine. But if not
        # I will get an exception that is catched in the 
        # try block. If the response is a '' the coerce into Numeric
        # would create a 0. So I have to skip then.
        try { $possible_num = $response.Numeric } unless '' eq $response;
        given $possible_num {
            when $_ ~~ Numeric
                { $result = $possible_num }
            when ''
                { $result = $default // Nil }
            default
                { $result = Nil }
        }

        last if defined $result;
        last if not self._do_say( $.lang_prompt_rat_retry );
    }
 
   return $result;
}


## Str type, can hold anything that can be read from IO
## (not sure if this is true...?) This is the default.
##
method ask_str ( Str $message=$!message,
                 $default=$!default ) returns Str {

    my Str $result;
    my Str $prompt = "{$message ?? "$message " !! ''}[{
                       $default // $.lang_prompt_str}] ";

    loop {
        my Str $response = self._do_prompt( $prompt );

        given $response {
            when ''
                { $result = $default // '' }
            default
                { $result = ~$response }
        }

        last if defined $result;
        last if not self._do_say( $.lang_prompt_str_retry );
    }
 
   return $result // Str;
}

# vim: ft=perl6
