use v6;
unit package SQL;

# largely based on https://ronsavage.github.io/SQL/sql-2003-2.bnf

grammar Keyword:ver<0.1.1> {
    token keyword               { <non-reserved-word> | <reserved-word> }

    token non-reserved-word {
        A
      | ABS
      | ABSOLUTE
      | ACTION
      | ADA
      | ADMIN
      | AFTER
      | ALWAYS
      | ASC
      | ASSERTION
      | ASSIGNMENT
      | ATTRIBUTE
      | ATTRIBUTES
      | AVG
      | BEFORE
      | BERNOULLI
      | BREADTH
      | C
      | CARDINALITY
      | CASCADE
      | CATALOG
      | CATALOG_NAME
      | CEIL
      | CEILING
      | CHAIN
      | CHARACTERISTICS
      | CHARACTERS
      | CHARACTER_LENGTH
      | CHARACTER_SET_CATALOG
      | CHARACTER_SET_NAME
      | CHARACTER_SET_SCHEMA
      | CHAR_LENGTH
      | CHECKED
      | CLASS_ORIGIN
      | COALESCE
      | COBOL
      | CODE_UNITS
      | COLLATION
      | COLLATION_CATALOG
      | COLLATION_NAME
      | COLLATION_SCHEMA
      | COLLECT
      | COLUMN_NAME
      | COMMAND_FUNCTION
      | COMMAND_FUNCTION_CODE
      | COMMITTED
      | CONDITION
      | CONDITION_NUMBER
      | CONNECTION_NAME
      | CONSTRAINTS
      | CONSTRAINT_CATALOG
      | CONSTRAINT_NAME
      | CONSTRAINT_SCHEMA
      | CONSTRUCTORS
      | CONTAINS
      | CONVERT
      | CORR
      | COUNT
      | COVAR_POP
      | COVAR_SAMP
      | CUME_DIST
      | CURRENT_COLLATION
      | CURSOR_NAME
      | DATA
      | DATETIME_INTERVAL_CODE
      | DATETIME_INTERVAL_PRECISION
      | DEFAULTS
      | DEFERRABLE
      | DEFERRED
      | DEFINED
      | DEFINER
      | DEGREE
      | DENSE_RANK
      | DEPTH
      | DERIVED
      | DESC
      | DESCRIPTOR
      | DIAGNOSTICS
      | DISPATCH
      | DOMAIN
      | DYNAMIC_FUNCTION
      | DYNAMIC_FUNCTION_CODE
      | EQUALS
      | EVERY
      | EXCEPTION
      | EXCLUDE
      | EXCLUDING
      | EXP
      | EXTRACT
      | FINAL
      | FIRST
      | FLOOR
      | FOLLOWING
      | FORTRAN
      | FOUND
      | FUSION
      | G
      | GENERAL
      | GO
      | GOTO
      | GRANTED
      | HIERARCHY
      | IF
      | IMPLEMENTATION
      | INCLUDING
      | INCREMENT
      | INITIALLY
      | INSTANCE
      | INSTANTIABLE
      | INTERSECTION
      | INVOKER
      | ISOLATION
      | K
      | KEY
      | KEY_MEMBER
      | KEY_TYPE
      | LAST
      | LENGTH
      | LEVEL
      | LN
      | LOCATOR
      | LOWER
      | M
      | MAP
      | MATCHED
      | MAX
      | MAXVALUE
      | MESSAGE_LENGTH
      | MESSAGE_OCTET_LENGTH
      | MESSAGE_TEXT
      | MIN
      | MINVALUE
      | MOD
      | MORE
      | MUMPS
      | NAME
      | NAMES
      | NESTING
      | NEXT
      | NORMALIZE
      | NORMALIZED
      | NULLABLE
      | NULLIF
      | NULLS
      | NUMBER
      | OBJECT
      | OCTETS
      | OCTET_LENGTH
      | OPTION
      | OPTIONS
      | ORDERING
      | ORDINALITY
      | OTHERS
      | OVERLAY
      | OVERRIDING
      | PAD
      | PARAMETER_MODE
      | PARAMETER_NAME
      | PARAMETER_ORDINAL_POSITION
      | PARAMETER_SPECIFIC_CATALOG
      | PARAMETER_SPECIFIC_NAME
      | PARAMETER_SPECIFIC_SCHEMA
      | PARTIAL
      | PASCAL
      | PATH
      | PERCENTILE_CONT
      | PERCENTILE_DISC
      | PERCENT_RANK
      | PLACING
      | PLI
      | POSITION
      | POWER
      | PRECEDING
      | PRESERVE
      | PRIOR
      | PRIVILEGES
      | PUBLIC
      | RANK
      | READ
      | RELATIVE
      | REPEATABLE
      | RESTART
      | RETURNED_CARDINALITY
      | RETURNED_LENGTH
      | RETURNED_OCTET_LENGTH
      | RETURNED_SQLSTATE
      | ROLE
      | ROUTINE
      | ROUTINE_CATALOG
      | ROUTINE_NAME
      | ROUTINE_SCHEMA
      | ROW_COUNT
      | ROW_NUMBER
      | SCALE
      | SCHEMA
      | SCHEMA_NAME
      | SCOPE_CATALOG
      | SCOPE_NAME
      | SCOPE_SCHEMA
      | SECTION
      | SECURITY
      | SELF
      | SEQUENCE
      | SERIALIZABLE
      | SERVER_NAME
      | SESSION
      | SETS
      | SIMPLE
      | SIZE
      | SOURCE
      | SPACE
      | SPECIFIC_NAME
      | SQRT
      | STATE
      | STATEMENT
      | STDDEV_POP
      | STDDEV_SAMP
      | STRUCTURE
      | STYLE
      | SUBCLASS_ORIGIN
      | SUBSTRING
      | SUM
      | TABLESAMPLE
      | TABLE_NAME
      | TEMPORARY
      | TIES
      | TOP_LEVEL_COUNT
      | TRANSACTION
      | TRANSACTIONS_COMMITTED
      | TRANSACTIONS_ROLLED_BACK
      | TRANSACTION_ACTIVE
      | TRANSFORM
      | TRANSFORMS
      | TRANSLATE
      | TRIGGER_CATALOG
      | TRIGGER_NAME
      | TRIGGER_SCHEMA
      | TRIM
      | TYPE
      | UNBOUNDED
      | UNCOMMITTED
      | UNDER
      | UNNAMED
      | USAGE
      | USER_DEFINED_TYPE_CATALOG
      | USER_DEFINED_TYPE_CODE
      | USER_DEFINED_TYPE_NAME
      | USER_DEFINED_TYPE_SCHEMA
      | VIEW
      | WORK
      | WRITE
      | ZONE
    }

    token reserved-word         {
        ADD
      | ALL
      | ALLOCATE
      | ALTER
      | AND
      | ANY
      | ARE
      | ARRAY
      | AS
      | ASENSITIVE
      | ASYMMETRIC
      | AT
      | ATOMIC
      | AUTHORIZATION
      | BEGIN
      | BETWEEN
      | BIGINT
      | BINARY
      | BLOB
      | BOOLEAN
      | BOTH
      | BY
      | CALL
      | CALLED
      | CASCADED
      | CASE
      | CAST
      | CHAR
      | CHARACTER
      | CHECK
      | CLOB
      | CLOSE
      | COLLATE
      | COLUMN
      | COMMIT
      | CONNECT
      | CONSTRAINT
      | CONTINUE
      | CORRESPONDING
      | CREATE
      | CROSS
      | CUBE
      | CURRENT
      | CURRENT_DATE
      | CURRENT_DEFAULT_TRANSFORM_GROUP
      | CURRENT_PATH
      | CURRENT_ROLE
      | CURRENT_TIME
      | CURRENT_TIMESTAMP
      | CURRENT_TRANSFORM_GROUP_FOR_TYPE
      | CURRENT_USER
      | CURSOR
      | CYCLE
      | DATE
      | DAY
      | DEALLOCATE
      | DEC
      | DECIMAL
      | DECLARE
      | DEFAULT
      | DELETE
      | DEREF
      | DESCRIBE
      | DETERMINISTIC
      | DISCONNECT
      | DISTINCT
      | DOUBLE
      | DROP
      | DYNAMIC
      | EACH
      | ELEMENT
      | ELSE
      | END
      | END\-EXEC
      | ESCAPE
      | EXCEPT
      | EXEC
      | EXECUTE
      | EXISTS
      | EXTERNAL
      | FALSE
      | FETCH
      | FILTER
      | FLOAT
      | FOR
      | FOREIGN
      | FREE
      | FROM
      | FULL
      | FUNCTION
      | GET
      | GLOBAL
      | GRANT
      | GROUP
      | GROUPING
      | HAVING
      | HOLD
      | HOUR
      | IDENTITY
      | IMMEDIATE
      | IN
      | INDEX
      | INDICATOR
      | INNER
      | INOUT
      | INPUT
      | INSENSITIVE
      | INSERT
      | INT
      | INTEGER
      | INTERSECT
      | INTERVAL
      | INTO
      | IS
      | ISOLATION
      | JOIN
      | LANGUAGE
      | LARGE
      | LATERAL
      | LEADING
      | LEFT
      | LIKE
      | LOCAL
      | LOCALTIME
      | LOCALTIMESTAMP
      | MATCH
      | MEMBER
      | MERGE
      | METHOD
      | MINUTE
      | MODIFIES
      | MODULE
      | MONTH
      | MULTISET
      | NATIONAL
      | NATURAL
      | NCHAR
      | NCLOB
      | NEW
      | NO
      | NONE
      | NOT
      | NULL
      | NUMERIC
      | OF
      | OLD
      | ON
      | ONLY
      | OPEN
      | OR
      | ORDER
      | OUT
      | OUTER
      | OUTPUT
      | OVER
      | OVERLAPS
      | PARAMETER
      | PARTITION
      | PRECISION
      | PREPARE
      | PRIMARY
      | PROCEDURE
      | RANGE
      | READS
      | REAL
      | RECURSIVE
      | REF
      | REFERENCES
      | REFERENCING
      | REGR_AVGX
      | REGR_AVGY
      | REGR_COUNT
      | REGR_INTERCEPT
      | REGR_R2
      | REGR_SLOPE
      | REGR_SXX
      | REGR_SXY
      | REGR_SYY
      | RELEASE
      | RESULT
      | RETURN
      | RETURNS
      | REVOKE
      | RIGHT
      | ROLLBACK
      | ROLLUP
      | ROW
      | ROWS
      | SAVEPOINT
      | SCROLL
      | SEARCH
      | SECOND
      | SELECT
      | SENSITIVE
      | SESSION_USER
      | SET
      | SIMILAR
      | SMALLINT
      | SOME
      | SPECIFIC
      | SPECIFICTYPE
      | SQL
      | SQLEXCEPTION
      | SQLSTATE
      | SQLWARNING
      | START
      | STATIC
      | SUBMULTISET
      | SYMMETRIC
      | SYSTEM
      | SYSTEM_USER
      | TABLE
      | THEN
      | TIME
      | TIMESTAMP
      | TIMEZONE_HOUR
      | TIMEZONE_MINUTE
      | TO
      | TRAILING
      | TRANSLATION
      | TREAT
      | TRIGGER
      | TRUE
      | UESCAPE
      | UNION
      | UNIQUE
      | UNKNOWN
      | UNNEST
      | UPDATE
      | UPPER
      | USER
      | USING
      | VALUE
      | VALUES
      | VAR_POP
      | VAR_SAMP
      | VARCHAR
      | VARYING
      | WHEN
      | WHENEVER
      | WHERE
      | WIDTH_BUCKET
      | WINDOW
      | WITH
      | WITHIN
      | WITHOUT
      | YEAR
    }
}

grammar Lexer:ver<0.2.2> is Keyword {
    my Str $oq;

    regex ascii-digit           { <:N> & <:Block(｢Basic Latin｣)> }
#   regex SQL-special-char { <[ \x[0020] "%&'()*+,\-./:;<=>?[ \x[005D] ^_|{} ]> }
#   regex SQL-language-char     { <ascii-digit> | <SQL-special-char> | <:L> }
    regex identifier-start      { <:L> & <:Script<Latin>> }
    regex identifier-part       { <identifier-start> | <ascii-digit> }
    regex singlequote           { <[']> }
    regex doublequote           { <["]> }
    regex non-quote-char        { <-['"\n]> }
    regex quote                 { <singlequote> | <doublequote> }
    regex comment-char          { <quote> | <non-quote-char> }
    regex char-representation {
        $($oq) $($oq) | <non-quote-char> | [ <quote> <!after $($oq) > ]
    }
    regex period                { <[.]> }
    regex underscore            { <[_]> }
    regex plus-sign             { <[+]> }
    regex minus-sign            { <[-]> }
    regex sign                  { <+plus-sign +minus-sign> }
    regex left-paren            { <[(]> }
    regex right-paren           { <[)]> }
    regex colon                 { <[:]> }
    regex semicolon             { <[;]> }
    regex comma                 { <[,]> }
    regex solidus               { <[/]> }

    regex simple-comment-introducer {
        <[-]> ** 2..*
      | <[#]> +
    }

    regex bracketed-comment-introducer { "/*" }
    regex bracketed-comment-terminator { "*/" }
    regex bracketed-comment {
        <bracketed-comment-introducer> .*? <bracketed-comment-terminator>
    }

    token separator             { \s+ || <comment> }
    token comment               {
        <simple-comment>
      | <bracketed-comment>
    }
    token simple-comment        {
        <simple-comment-introducer>
        <comment-char> *
        <[\n]>
    }

    token unsigned-integer      { <ascii-digit>+ }
    token signed-integer        { <[ + - ]>? <unsigned-integer> }

    token identifier-body       { <identifier-start> [ <identifier-part> | '_' ]* }
    token regular-identifier    { <identifier-body> }

    token literal               { <signed-numeric-literal> | <general-literal> }

    token exact-numeric-literal {
        <unsigned-integer> [ '.' <unsigned-integer>? ]?
      | '.' <unsigned-integer>
    }
    token approximate-numeric-literal {
        <exact-numeric-literal> E <signed-integer>
    }
    token unsigned-numeric-literal {
        <exact-numeric-literal> | <exact-numeric-literal>
    }
    token signed-numeric-literal {
        <[ + - ]>? <unsigned-numeric-literal>
    }
    token char-string-literal-base {
        $<opening-quote>=<quote>  { $oq = $<opening-quote>.Str }
        <char-representation>*
        $($<opening-quote>)
    }
    token char-string-literal {
        [ '_' <char-set-spec> ] ?
        <char-string-literal-base>
        [ <separator> <char-string-literal-base> ]*
    }
    token national-char-string-literal {
        N <char-string-literal-base>
        [ <separator> <quote> <char-string-literal-base> ]*
    }

    token datetime-literal { <date-literal> | <time-literal> | <timestamp-literal> }

    rule date-literal { DATE <date-string> }
    rule time-literal { TIME <time-string> }
    rule timestamp-literal { TIMESTAMP <timestamp-string> }
    token date-string {
        $<opening-quote>=<quote> <unquoted-date-string> {} $($<opening-quote>)
    }
    token time-string {
        $<opening-quote>=<quote> <unquoted-time-string> {} $($<opening-quote>)
    }
    token timestamp-string {
        $<opening-quote>=<quote> <unquoted-timestamp-string> {} $($<opening-quote>)
    }
    token unquoted-date-string      { <date-value> }
    token unquoted-time-string      { <time-value> <time-zone-interval>? }
    token unquoted-timestamp-string { <unquoted-date-string> <space> <unquoted-time-string> }
    token date-value {
        <years-value> <minus-sign> <months-value> <minus-sign> <days-value>
    }
    token time-value {
        <hours-value> <colon> <minutes-value> <colon> <seconds-value>
    }
    token time-zone-interval {
        <sign> <hours-value> <colon> <minutes-value>
    }

    rule interval-literal { INTERVAL <sign>? <interval-string> <interval-qualifier> }
    token interval-string {
        $<opening-quote>=<quote> <unquoted-interval-string> {} $($<opening-quote>)
    }
    token unquoted-interval-string  { <sign>? [ <year-month-literal> | <day-time-literal> ] }
    token year-month-literal { <years-value> | [ <years-value> <minus-sign> ]? <months-value> }
    token day-time-literal { <day-time-interval> | <time-interval> }
    token day-time-interval {
        <days-value> [ <space> <basic-time-interval> ]?
    }
    token full-time-interval {
        <hours-value> [
        <colon> <minutes-value> [
        <colon> <seconds-value>
        ]? ]?
    }
    token time-interval {
        <full-time-interval>
     || <minutes-value> [ <colon> <seconds-value> ]?
     || <seconds-value>
    }
    token years-value   { <unsigned-integer> }
    token months-value  { <unsigned-integer> }
    token days-value    { <unsigned-integer> }
    token hours-value   { <unsigned-integer> }
    token minutes-value { <unsigned-integer> }
    token seconds-value { <unsigned-integer> [ <period> [ <unsigned-integer> ]? ]? }
    rule interval-qualifier {
        <start-field> TO <end-field>
     || <single-datetime-field>
    }
    token start-field {
        <non-second-primary-datetime-field> [
            <left-paren> <interval-leading-field-precision> <right-paren>
        ]?
    }
    token end-field {
        <non-second-primary-datetime-field>
     || SECOND [
            <left-paren> <interval-fractional-seconds-precision> <right-paren>
        ]?
    }
    token single-datetime-field {
        <non-second-primary-datetime-field>
     || SECOND [
            <left-paren> <interval-leading-field-precision> [
                <comma> <interval-fractional-seconds-precision>
            ]?
            <right-paren>
        ]?
    }
    token primary-datetime-field {
        <non-second-primary-datetime-field>
     || SECOND
    }
    token non-second-primary-datetime-field {
        YEAR
     || MONTH
     || DAY
     || HOUR
     || MINUTE
    }
    token interval-leading-field-precision      { <unsigned-integer> }
    token interval-fractional-seconds-precision { <unsigned-integer> }

    token boolean-literal { TRUE || FALSE || UNKNOWN }

    token general-literal {
        <char-string-literal>
      | <national-char-string-literal>
    # | <Unicode-char-string-literal>
    # | <binary-string-literal>
      | <datetime-literal>
      | <interval-literal>
      | <boolean-literal>
    }

    token operator-symbol {
        <equals-operator>
     || <non-equals-operator>
     || <less-than-operator>
     || <greater-than-operator>
     || <plus-operator>
     || <minus-operator>
     || <multiply-operator>
     || <divide-operator>
     || <greater-than-or-equals-operator>
     || <less-than-or-equals-operator>
    }
    token equals-operator                   { '=' }
    token non-equals-operator               { '!=' }
    token less-than-operator                { '<' }
    token greater-than-operator             { '>' }
    token plus-operator                     { <plus-sign> }
    token minus-operator                    { <minus-sign> }
    token multiply-operator                 { '*' }
    token divide-operator                   { <solidus> }
    token greater-than-or-equals-operator   { <greater-than-operator> <equals-operator> }
    token less-than-or-equals-operator      { <less-than-operator> <equals-operator> }

    # not in the SQL2003 bnf
    regex backquote                         { '`' }
    token quoted-label                      { <backquote> <regular-identifier> <backquote> }

    token variable                          {
        [ <system-variable-sigil> | <session-variable-sigil> ]
        <regular-identifier>
    }
    regex system-variable-sigil             { '@@' }
    regex session-variable-sigil            { '@' }
}

# some tokens not yet implemented
#`{
    token schema-name {
        [ <catalog-name> '.' ]? <unqualified-schema-name>
    }

    token char-set-spec {
        <standard-char-set-name>
    # | <implementation-defined-char-set-name>
    # | <user-defined-char-set-name>
    }

    token standard-char-set-name {
        <character-set-name>
    }

    token character-set-name {
        <schema-name> '.' <SQL-language-identifier>
    }

    token nondelimiter-token {
        <regular-identifier>
      | <keyword>
      | <unsigned-numeric-literal>
      | <national-char-string-literal>
    # | <bit-string-literal>
    # | <hex-string-literal>
    # | <large-object-length-token>
    # | <multiplier>
    }
}

