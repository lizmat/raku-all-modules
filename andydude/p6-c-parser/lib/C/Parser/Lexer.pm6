# References ISO/IEC 9899:1990 "Information technology - Programming Language C" (C89 for short)
use v6;
#use Grammar::Tracer;
unit grammar C::Parser::Lexer;

token TOP {^ <.ws> <c-tokens> [$ || {die("expected eof")}] }

token ws {
    <.ws-char>*
}

token ws-char {
    <[\ \t\r\n]>
}

rule c-tokens {
     <c-token>+
}

rule pp-tokens {
     <pp-token>+
}


############################################################
##
##  Keywords
##

# SS 6.4
proto rule c-token {*}
rule c-token:sym<keyword> { <keyword> }
rule c-token:sym<identifier> { <ident> }
rule c-token:sym<constant> { <constant> }
rule c-token:sym<string-literal> { <string-literal> }
rule c-token:sym<punct> { <punct> }

proto rule pp-token {*}
rule pp-token:sym<header-name> { <header-name> }
rule pp-token:sym<identifier> { <ident> }
rule pp-token:sym<pp-number> { <pp-number> }
rule pp-token:sym<character-constant> { <character-constant> }
rule pp-token:sym<string-literal> { <string-literal> }
rule pp-token:sym<punct> { <punct> }
rule pp-token:sym<none-of-above> { { say "none-of-the-above"; } <!> }

# SS 6.4.1
proto token keyword {*}
token keyword:sym<auto>     { <auto-keyword> }
token keyword:sym<break>    { <break-keyword> }
token keyword:sym<case>     { <case-keyword> }
token keyword:sym<char>     { <char-keyword> }
token keyword:sym<const>    { <const-keyword> }
token keyword:sym<continue> { <continue-keyword> }
token keyword:sym<default>  { <default-keyword> }
token keyword:sym<do>       { <do-keyword> }
token keyword:sym<double>   { <double-keyword> }
token keyword:sym<else>     { <else-keyword> }
token keyword:sym<enum>     { <enum-keyword> }
token keyword:sym<extern>   { <extern-keyword> }
token keyword:sym<float>    { <float-keyword> }
token keyword:sym<for>      { <for-keyword> }
token keyword:sym<goto>     { <goto-keyword> }
token keyword:sym<if>       { <if-keyword> }
token keyword:sym<inline>   { <inline-keyword> }
token keyword:sym<int>      { <int-keyword> }
token keyword:sym<long>     { <long-keyword> }
token keyword:sym<register> { <register-keyword> }
token keyword:sym<restrict> { <restrict-keyword> }
token keyword:sym<return>   { <return-keyword> }
token keyword:sym<short>    { <short-keyword> }
token keyword:sym<signed>   { <signed-keyword> }
token keyword:sym<sizeof>   { <sizeof-keyword> }
token keyword:sym<static>   { <static-keyword> }
token keyword:sym<struct>   { <struct-keyword> }
token keyword:sym<switch>   { <switch-keyword> }
token keyword:sym<typedef>  { <typedef-keyword> }
token keyword:sym<union>    { <union-keyword> }
token keyword:sym<unsigned> { <unsigned-keyword> }
token keyword:sym<void>     { <void-keyword> }
token keyword:sym<volatile> { <volatile-keyword> }
token keyword:sym<while>    { <while-keyword> }
token keyword:sym<_Alignas> { <alignas-keyword> }
token keyword:sym<_Alignof> { <alignof-keyword> }
token keyword:sym<_Atomic>  { <atomic-keyword> }
token keyword:sym<_Bool>    { <bool-keyword> }
token keyword:sym<_Complex> { <complex-keyword> }
token keyword:sym<_Generic> { <generic-keyword> }
token keyword:sym<_Imaginary>     { <imaginary-keyword> }
token keyword:sym<_Noreturn>      { <noreturn-keyword> }
token keyword:sym<_Static_assert> { <static-assert-keyword> }
token keyword:sym<_Thread_local>  { <thread-local-keyword> }

token keyword-breaker {
    <!before <[_A..Za..z0..9]>>
}

# Ancient keywords
token auto-keyword     { 'auto'     <.keyword-breaker> }
token break-keyword    { 'break'    <.keyword-breaker> }
token case-keyword     { 'case'     <.keyword-breaker> }
token char-keyword     { 'char'     <.keyword-breaker> }
token const-keyword    { 'const'    <.keyword-breaker> }
token continue-keyword { 'continue' <.keyword-breaker> }
token default-keyword  { 'default'  <.keyword-breaker> }
token do-keyword       { 'do'       <.keyword-breaker> }
token double-keyword   { 'double'   <.keyword-breaker> }
token else-keyword     { 'else'     <.keyword-breaker> }
token enum-keyword     { 'enum'     <.keyword-breaker> }
token extern-keyword   { 'extern'   <.keyword-breaker> }
token float-keyword    { 'float'    <.keyword-breaker> }
token for-keyword      { 'for'      <.keyword-breaker> }
token goto-keyword     { 'goto'     <.keyword-breaker> }
token if-keyword       { 'if'       <.keyword-breaker> }
token int-keyword      { 'int'      <.keyword-breaker> }
token long-keyword     { 'long'     <.keyword-breaker> }
token register-keyword { 'register' <.keyword-breaker> }
token return-keyword   { 'return'   <.keyword-breaker> }
token short-keyword    { 'short'    <.keyword-breaker> }
token signed-keyword   { 'signed'   <.keyword-breaker> }
token sizeof-keyword   { 'sizeof'   <.keyword-breaker> }
token static-keyword   { 'static'   <.keyword-breaker> }
token struct-keyword   { 'struct'   <.keyword-breaker> }
token switch-keyword   { 'switch'   <.keyword-breaker> }
token typedef-keyword  { 'typedef'  <.keyword-breaker> }
token union-keyword    { 'union'    <.keyword-breaker> }
token unsigned-keyword { 'unsigned' <.keyword-breaker> }
token void-keyword     { 'void'     <.keyword-breaker> }
token volatile-keyword { 'volatile' <.keyword-breaker> }
token while-keyword    { 'while'    <.keyword-breaker> }

# Standard extension keywords
token inline-keyword        { '_Inline' || 'inline' || '__inline' || '__inline__' }         # C99
token restrict-keyword      { '_Restrict' || 'restrict' || '__restrict' || '__restrict__' } # C99
token alignas-keyword       { '_Alignas' || 'alignas' <.keyword-breaker> }                  # C11
token alignof-keyword       { '_Alignof' || 'alignof' <.keyword-breaker> }                  # C11
token atomic-keyword        { '_Atomic' || 'atomic' <.keyword-breaker> }                    # C11
token bool-keyword          { '_Bool' || 'bool' <.keyword-breaker> }                        # C99
token complex-keyword       { '_Complex' || 'complex' <.keyword-breaker> }                  # C99
token generic-keyword       { '_Generic' || 'generic' <.keyword-breaker> }                  # C11
token imaginary-keyword     { '_Imaginary' || 'imaginary' <.keyword-breaker> }              # C99
token noreturn-keyword      { '_Noreturn' || 'noreturn' <.keyword-breaker> }                # C11
token static-assert-keyword { '_Static_assert' || 'static_assert' }                         # C11
token thread-local-keyword  { '_Thread_local' || 'thread_local' }                           # C11
token accum-keyword         { '_Accum' <.keyword-breaker> }                                 # DSP
token fract-keyword         { '_Fract' <.keyword-breaker> }                                 # DSP
token sat-keyword           { '_Sat'   <.keyword-breaker> }                                 # DSP

# Nonstandard extension keywords
token asm-keyword           { '__asm__' || '__asm' || 'asm' <.keyword-breaker> }            # C++
token attribute-keyword     { '__attribute__' }                                             # GNU
token extension-keyword     { '__extension__' }                                             # GNU
token block-keyword         { '__block' }                                                   # Apple
token typeof-keyword        { '__typeof__' || 'typeof' <.keyword-breaker> }                 # GNU
token offsetof-keyword      { '__builtin_offsetof' }                                        # GNU


############################################################
##
##  Identifiers
##

# SS 6.4.2.1

# Standard name: identifier
# Nonstandard name: ident
# Rationale: 'ident' is more Perl-ish
token ident {
    <!before <keyword>>
    $<name>=(<.ident-first> <.ident-rest>*)
}

# identifier-nondigit
proto token ident-first {*}
token ident-first:sym<under> { '_' }
token ident-first:sym<alpha> { <.alpha> }
#token ident-first:sym<unichar> { <.universal-character-name> }

# identifier-nondigit | digit
proto token ident-rest {*}
token ident-rest:sym<alpha> { <.ident-first> }
token ident-rest:sym<digit> { <.digit> }

## digit is built-in in Perl6
##token digit { <[0..9]> }
##token alpha { <[a..zA..Z]> }


############################################################
##
##  Constants
##

# SS 6.4.3

proto token universal-character-name {*}
token universal-character-name:sym<u> { '\\u' <xdigit> ** 4 }
token universal-character-name:sym<U> { '\\U' <xdigit> ** 8 }

proto token constant {*}
token constant:sym<floating> {
    <floating-constant>
}
token constant:sym<integer> {
    <integer-constant>
    <!before [.eE]>
}
token constant:sym<enumeration> {
    <enumeration-constant>
}
token constant:sym<character> {
    <character-constant>
}

# SS 6.4.4.1

token integer-constant { <integer-value> <integer-suffix>* }

# Nonstandard: integer-value does not exist in C89 grammar
# Rationale: <integer-suffix> appears on the RHS of every
# rule in the C89 grammar, so we factor it out here.
proto token integer-value {*}
token integer-value:sym<8>  { <octal-constant> }
token integer-value:sym<10> { <decimal-constant> }
token integer-value:sym<16> { <hexadecimal-constant> }

token octal-constant { '0' <odigit>* }
token decimal-constant { <nzdigit> <digit>* }
token hexadecimal-constant { <.hexadecimal-prefix> <xdigit>* }
token hexadecimal-prefix { '0' <[xX]> }

token nzdigit { <[1..9]> }
token odigit { <[0..7]> }

proto token integer-suffix {*}
token integer-suffix:sym<L> { <[lL]> }
token integer-suffix:sym<LL> { < ll LL > }
token integer-suffix:sym<U> { <[uU]> }

# SS 6.4.4.2
proto token floating-constant {*}
token floating-constant:radix<10> { <decimal-floating-constant> }
token floating-constant:radix<16> { <hexadecimal-floating-constant> }

proto token decimal-floating-constant {*}
token decimal-floating-constant:sym<9.9> {
      <fractional-constant> <exponent-part>? <floating-suffix>?
}
token decimal-floating-constant:sym<9e9> {
      <digit-sequence> <exponent-part> <floating-suffix>?
}

proto token hexadecimal-floating-constant {*}
token hexadecimal-floating-constant:sym<F.F> {
      <hexadecimal-prefix>
      <hexadecimal-fractional-constant>
      <binary-exponent-part>
      <floating-suffix>?
}
token hexadecimal-floating-constant:sym<FpF> {
      <hexadecimal-prefix>
      <hexadecimal-digit-sequence>
      <binary-exponent-part>
      <floating-suffix>?
}

proto token fractional-constant {*}
token fractional-constant:sym<9.9> {
      <digit-sequence>? '.' <digit-sequence>
}
token fractional-constant:sym<9.> {
      <digit-sequence> '.'
}

token exponent-part { <[eE]> <sign>? <digit-sequence> }

token sign { <[+-]> }

token digit-sequence { <.digit>+ }

proto token hexadecimal-fractional-constant {*}
token hexadecimal-fractional-constant:sym<F.F> {
      <hexadecimal-digit-sequence>? '.' <hexadecimal-digit-sequence>
}
token hexadecimal-fractional-constant:sym<F.> {
      <hexadecimal-digit-sequence> '.'
}

token binary-exponent-part { <[pP]> <sign>? <digit-sequence> }

token hexadecimal-digit-sequence { <.xdigit>+ }

proto token floating-suffix {*}
token floating-suffix:sym<F> { <[fF]> }
token floating-suffix:sym<L> { <[lL]> }

# SS 6.4.4.3
token enumeration-constant { <ident> }

# SS 6.4.4.4
proto token character-constant {*}
token character-constant:sym<quote> { "'" <c-char-sequence>? "'" }
token character-constant:sym<L> { <sym> "'" <c-char-sequence>? "'" } # C99 wchar_t
token character-constant:sym<u> { <sym> "'" <c-char-sequence>? "'" } # C11 char16_t
token character-constant:sym<U> { <sym> "'" <c-char-sequence>? "'" } # C11 char32_t

token c-char-sequence { <c-char>+ }

proto token c-char {*}
token c-char:sym<any> { <-[\'\\\n]> }
token c-char:sym<escape> { <escape-sequence> }

proto token escape-sequence {*}
token escape-sequence:sym<simple> { <simple-escape-sequence> }
token escape-sequence:sym<octal> { <octal-escape-sequence> }
token escape-sequence:sym<hexadecimal> { <hexadecimal-escape-sequence> }
token escape-sequence:sym<universal> { <.universal-character-name> }

proto token simple-escape-sequence {*}
token simple-escape-sequence:sym<\\> { '\\' '\\' }
token simple-escape-sequence:sym<'> { '\\' <sym> }
token simple-escape-sequence:sym<"> { '\\' <sym> }
token simple-escape-sequence:sym<?> { '\\' <sym> }
token simple-escape-sequence:sym<a> { '\\' <sym> }
token simple-escape-sequence:sym<b> { '\\' <sym> }
token simple-escape-sequence:sym<f> { '\\' <sym> }
token simple-escape-sequence:sym<n> { '\\' <sym> }
token simple-escape-sequence:sym<r> { '\\' <sym> }
token simple-escape-sequence:sym<t> { '\\' <sym> }
token simple-escape-sequence:sym<v> { '\\' <sym> }

token octal-escape-sequence { '\\' <odigit> ** 1..3 }
token hexadecimal-escape-sequence { '\\x' <xdigit>+ }

# SS 6.4.5
proto token string-literal {*}
token string-literal:sym<quote> { '"' <s-char-sequence>? '"' }
token string-literal:sym<L>  { <sym> '"' <s-char-sequence>? '"' } # C99 wchar_t *
token string-literal:sym<u8> { <sym> '"' <s-char-sequence>? '"' } # C11 UTF-8
token string-literal:sym<u>  { <sym> '"' <s-char-sequence>? '"' } # C11 UTF-16 char16_t *
token string-literal:sym<U>  { <sym> '"' <s-char-sequence>? '"' } # C11 UTF-32 char32_t *

token s-char-sequence { <s-char>+ }

proto token s-char {*}
token s-char:sym<any> { <-[\"\\\n]> }
token s-char:sym<escape> { <escape-sequence> }

rule string-constant { [<string-literal> <.ws>]+ }

############################################################
##
##  Operators
##

# punctuator
proto token punct {*}
token punct:sym<pp(> { '(' } # TODO: check for <ws>
token punct:sym<(>   { <sym> }
token punct:sym<)>   { <sym> }
token punct:sym<[>   { <sym> | '<:' }
token punct:sym<]>   { <sym> | ':>' }
token punct:sym<{>   { <sym> | '<%' }
token punct:sym<}>   { <sym> | '%>' }
token punct:sym<.>   { <sym> }
token punct:sym«->»  { <sym> }
token punct:sym<++>  { <sym> }
token punct:sym<-->  { <sym> }
token punct:sym<&>   { <sym> }
token punct:sym<*>   { <sym> }
token punct:sym<+>   { <sym> }
token punct:sym<->   { <sym> }
token punct:sym<~>   { <sym> }
token punct:sym<!>   { <sym> }
token punct:sym</>   { <sym> }
token punct:sym<%>   { <sym> }
token punct:sym«<<»  { <sym> }
token punct:sym«>>»  { <sym> }
token punct:sym«<»   { <sym> }
token punct:sym«>»   { <sym> }
token punct:sym«<=»  { <sym> }
token punct:sym«>=»  { <sym> }
token punct:sym<==>  { <sym> }
token punct:sym<!=>  { <sym> }
token punct:sym<^>   { <sym> }
token punct:sym<|>   { <sym> }
token punct:sym<&&>  { <sym> }
token punct:sym<||>  { <sym> }
token punct:sym<?>   { <sym> }
token punct:sym<:>   { <sym> }
token punct:sym<;>   { <sym> }
token punct:sym<...> { <sym> }
token punct:sym<=>   { <sym> }
token punct:sym<*=>  { <sym> }
token punct:sym</=>  { <sym> }
token punct:sym<%=>  { <sym> }
token punct:sym<+=>  { <sym> }
token punct:sym<-=>  { <sym> }
token punct:sym«<<=» { <sym> }
token punct:sym«>>=» { <sym> }
token punct:sym<&=>  { <sym> }
token punct:sym<^=>  { <sym> }
token punct:sym<|=>  { <sym> }
token punct:sym<,>   { <sym> }
token punct:sym<#>   { <sym> | '%:' }
token punct:sym<##>  { <sym> | '%:%:' }

## SS 6.4.7
##proto token header-name {*}
##token header-name:sym<angle> { <.punct:sym«<»> <h-char-sequence> <.punct:sym«>»> }
##token header-name:sym<quote> { <.punct:sym<">> <q-char-sequence> <.punct:sym<">> }
##
##proto token h-char-sequence {*}
##token h-char { <-[\n\>]> }
##proto token q-char-sequence {*}
##token q-char { <-[\n\"]> }
##
##token pp-number {
##      <.pp-number-first>
##      <.pp-number-rest>*
##}
##
##proto token pp-number-first {*}
##token pp-number-first:sym<9> { <digit> }
##token pp-number-first:sym<.9> { '.' <digit> }
##
##proto token pp-number-rest {*}
##token pp-number-rest:sym<9> { <digit> }
##token pp-number-rest:sym<A> { <ident-first> }
##token pp-number-rest:sym<E> { <[eE]> <sign> }
##token pp-number-rest:sym<P> { <[pP]> <sign> }
##token pp-number-rest:sym<,> { '.' }
