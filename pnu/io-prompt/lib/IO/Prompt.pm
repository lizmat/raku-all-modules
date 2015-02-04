use v6;
class IO::Prompt {


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
      given $type        {
        when .^isa(Bool) { self.ask_yn(  |$args ); }
        when .^isa(Int)  { self.ask_int( |$args ); }
        when .^isa(Num)  { self.ask_num( |$args ); }
        when .^isa(Str)  { self.ask_str( |$args ); }
        default            {
          given $default     {
            when .^isa(Bool) { self.ask_yn(  |$args ); }
            when .^isa(Int)  { self.ask_int( |$args ); }
            when .^isa(Num)  { self.ask_num( |$args ); }
            when .^isa(Str)  { self.ask_str( |$args ); }
            default            { self.ask_str( |$args ); }
          } # given $default
        } # given $type default
      } # given $type
    };

    return $r;
}


## The low-level IO methods. Override for testing etc.
##
method !do_prompt ( Str $question? ) returns Str {
    return defined $question ?? prompt($question)
                             !! prompt('');
}

method !do_say ( Str $output ) returns Bool {
    say $output;
    return Bool::True;
    ## Return False, if there is no point to continue
}


## The strings and rules used in the low-level
## query methods. Override these class attributes
## for localization etc.
##
our Str $.lang_prompt_Yn        = 'Y/n';
our Str $.lang_prompt_yN        = 'y/N';
our Str $.lang_prompt_yn        = 'y/n';
our Str $.lang_prompt_yn_retry  = 'Please enter yes or no';
our     $.lang_prompt_match_y   = m/ ^^ <[yY]> /;
our     $.lang_prompt_match_n   = m/ ^^ <[nN]> /;
our Str $.lang_prompt_int       = 'Int';
our Str $.lang_prompt_int_retry = 'Please enter a valid integer';
our Str $.lang_prompt_num       = 'Num';
our Str $.lang_prompt_num_retry = 'Please enter a valid number';
our Str $.lang_prompt_str       = 'Str';
our Str $.lang_prompt_str_retry = 'Please enter a valid string';


## Object evaluation in various contexts (type coersion)
##
method true {
    return self.ask( $!message, $!default, :type($!type // Bool) );
}

method Int {
    return self.ask( $!message, $!default, :type($!type // Int) );
}

method Num {
    return self.ask( $!message, $!default, :type($!type // Num) );
}

method Str {
    return self.ask( $!message, $!default, :type($!type // Str) );
}


## Boolean Yes/No 
##
method ask_yn (  Str $message=$!message,
                Bool $default=$!default ) returns Bool {

    my Bool $result;
    my  Str $prompt = "{$message ?? "$message " !! ''}[{
            defined $default ?? $default ?? $.lang_prompt_Yn
            !! $.lang_prompt_yN !! $.lang_prompt_yn}] ";

    loop {
        my Str $response = self!do_prompt( $prompt );

        given $response {
            when $.lang_prompt_match_y { $result = Bool::True }
            when $.lang_prompt_match_n { $result = Bool::False }
            when ''                    { $result = $default }
            default                    { $result = undef }
        }
        last if defined $result;
        last if not self!do_say( $.lang_prompt_yn_retry );
    }

    return $result // Bool;
}


## Only Integers
##
method ask_int ( Str $message=$!message,
                 Int $default=$!default ) returns Int {

    my Int $result;
    my Str $prompt = "{$message ?? "$message " !! ''}[{
                       $default // $.lang_prompt_int}] ";

    loop {
        my Str $response = self!do_prompt( $prompt );

        given $response {
            when /^^ <Perl6::Grammar::integer> $$/
                { $result = int $response }
            when ''
                { $result = $default }
            default
                { $result = undef }
        }
        last if defined $result;
        last if not self!do_say( $.lang_prompt_int_retry );
    }
 
   return $result // Int;
}


## Numeric type, can hold integers, numbers and eventually rationals
##
method ask_num ( Str $message=$!message,
                 Num $default=$!default ) returns Num {

    my Num $result;
    my Str $prompt = "{$message ?? "$message " !! ''}[{
                       $default // $.lang_prompt_num}] ";

    loop {
        my Str $response = self!do_prompt( $prompt );

        given $response {
            when /^^ <Perl6::Grammar::number> $$/
                { $result = +$response }
            when ''
                { $result = $default }
            default
                { $result = undef }
        }

        last if defined $result;
        last if not self!do_say( $.lang_prompt_num_retry );
    }
 
   return $result // Num;
}


## Str type, can hold anything that can be read from IO
## (not sure if this is true...?) This is the default.
##
method ask_str ( Str $message=$!message,
                 Str $default=$!default ) returns Str {

    my Str $result;
    my Str $prompt = "{$message ?? "$message " !! ''}[{
                       $default // $.lang_prompt_str}] ";

    loop {
        my Str $response = self!do_prompt( $prompt );

        given $response {
            when ''
                { $result = $default }
            default
                { $result = ~$response }
        }

        last if defined $result;
        last if not self!do_say( $.lang_prompt_str_retry );
    }
 
   return $result // Str;
}

}

# vim: ft=perl6
