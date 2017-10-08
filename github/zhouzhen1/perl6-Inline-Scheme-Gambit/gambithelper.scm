(define-structure gambit-exception-wrapper exception)

(c-define (gambit-exception-wrapper-display exc) (scheme-object) char-string
    "gambit_exception_wrapper_display" "extern"
    (with-output-to-string '()
     (lambda () (display-exception (gambit-exception-wrapper-exception exc)))))

(c-define (gambit-eval p) (char-string) scheme-object
    "gambit_eval" "extern"
    (with-exception-catcher
        (lambda (exc) (make-gambit-exception-wrapper exc))
        (lambda () (eval (with-input-from-string p read)))))

(c-define (gambit-apply func args) (scheme-object scheme-object) scheme-object
    "gambit_apply" "extern"
    (with-exception-catcher
        (lambda (exc) (make-gambit-exception-wrapper exc))
        (lambda () (apply
         (if (string? func)
          (eval (string->symbol func)) func)
         args))))

(c-define (gambit-null) () scheme-object
    "gambit_null" "extern"
    '())

(define-macro (gambit-type-check sname cname checkf)
 `(c-define (,sname p) (scheme-object) bool
     ,cname "extern" (,checkf p)))

(gambit-type-check gambit-boolean-check "gambit_boolean_check" boolean?)
(gambit-type-check gambit-integer-check "gambit_integer_check" integer?)
(gambit-type-check gambit-rational-check "gambit_rational_check" rational?)
(gambit-type-check gambit-complex-check "gambit_complex_check" complex?)
(gambit-type-check gambit-exact-check "gambit_exact_check" exact?)
(gambit-type-check gambit-number-check "gambit_number_check" number?)
(gambit-type-check gambit-string-check "gambit_string_check" string?)
(gambit-type-check gambit-list-check "gambit_list_check" list?)
(gambit-type-check gambit-vector-check "gambit_vector_check" vector?)
(gambit-type-check gambit-pair-check "gambit_pair_check" pair?)
(gambit-type-check gambit-table-check "gambit_table_check" table?)
(gambit-type-check gambit-procedure-check "gambit_procedure_check" procedure?)
(gambit-type-check gambit-exception-wrapper-check "gambit_exception_wrapper_check" gambit-exception-wrapper?)

(define-macro (gambit-type-as-ctype sname cname ctype)
 `(c-define (,sname val) (scheme-object) ,ctype
     ,cname "extern" val))

(gambit-type-as-ctype gambit-boolean-as-bool "gambit_boolean_as_bool" bool)
(gambit-type-as-ctype gambit-integer-as-long "gambit_integer_as_long" long)
(gambit-type-as-ctype gambit-number-as-double "gambit_number_as_double" double)
(gambit-type-as-ctype gambit-string-as-string "gambit_string_as_string" char-string)

(define-macro (gambit-ctype-to-scheme sname cname ctype)
 `(c-define (,sname val) (,ctype) scheme-object
     ,cname "extern" val))

(gambit-ctype-to-scheme gambit-boolean-to-scheme "gambit_boolean_to_scheme" bool)
(gambit-ctype-to-scheme gambit-integer-to-scheme "gambit_integer_to_scheme" long)
(gambit-ctype-to-scheme gambit-number-to-scheme "gambit_number_to_scheme" double)
(gambit-ctype-to-scheme gambit-string-to-scheme "gambit_string_to_scheme" char-string)


(c-define (gambit-make-table) () scheme-object
    "gambit_make_table" "extern"
    (make-table))

(c-define (gambit-table-set table key val) (scheme-object scheme-object scheme-object) void
    "gambit_table_set" "extern"
    (table-set! table key val))

(c-define (gambit-table-to-list p) (scheme-object) scheme-object
    "gambit_table_to_list" "extern"
    (table->list p))

(c-define (gambit-list-to-vector p) (scheme-object) scheme-object
    "gambit_list_to_vector" "extern"
    (list->vector p))

(c-define (gambit-vector-length p) (scheme-object) long
    "gambit_vector_length" "extern"
    (vector-length p))

(c-define (gambit-vector-ref vec pos) (scheme-object long) scheme-object
    "gambit_vector_ref" "extern"
    (vector-ref vec pos))

(c-define (gambit-cons a b) (scheme-object scheme-object) scheme-object
    "gambit_cons" "extern"
    (cons a b))

(c-define (gambit-car p) (scheme-object) scheme-object
    "gambit_car" "extern"
    (car p))

(c-define (gambit-cdr p) (scheme-object) scheme-object
    "gambit_cdr" "extern"
    (cdr p))

