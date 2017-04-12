#include <libguile.h>
#include <stdio.h>
#include "guile_helper.h"

static void dump_scm( SCM scm )
	{
	printf("null              X: %d\n", scm_is_null              ( scm ));
	printf("bool              X: %d\n", scm_is_bool              ( scm ));
	printf("false             X: %d\n", scm_is_false             ( scm ));
	printf("true              X: %d\n", scm_is_true              ( scm ));
	printf("integer           X: %d\n", scm_is_integer           ( scm ));
	printf("string            X: %d\n", scm_is_string            ( scm ));
	printf("symbol            X: %d\n", scm_is_symbol            ( scm ));
	printf("array              : %d\n", scm_is_array             ( scm ));
	printf("bitvector          : %d\n", scm_is_bitvector         ( scm ));
	printf("bytevector         : %d\n", scm_is_bytevector        ( scm ));
	printf("complex           X: %d\n", scm_is_complex           ( scm ));
	printf("dynamic_state      : %d\n", scm_is_dynamic_state     ( scm ));
/*
	printf("exact              : %d\n", scm_is_exact             ( scm ));
*/
	printf("generalized_vector : %d\n", scm_is_generalized_vector( scm ));
/*
	printf("inexact            : %d\n", scm_is_inexact           ( scm ));
*/
	printf("keyword           X: %d\n", scm_is_keyword           ( scm ));
	printf("number            X: %d\n", scm_is_number            ( scm ));
	printf("rational          X: %d\n", scm_is_rational          ( scm ));
	printf("real              X: %d\n", scm_is_real              ( scm ));
	//printf("signed_integer     : %d\n", scm_is_signed_integer    ( scm ));
	printf("simple_vector      : %d\n", scm_is_simple_vector     ( scm ));
	//printf("typed_array        : %d\n", scm_is_typed_array       ( scm ));
	printf("uniform_vector     : %d\n", scm_is_uniform_vector    ( scm ));
	//printf("unsigned_integer   : %d\n", scm_is_unsigned_integer  ( scm ));
	printf("vector             : %d\n", scm_is_vector            ( scm ));
	printf("pair               : %d\n", scm_is_pair              ( scm ));
        printf("\n");
	}

static void _display_list( cons_cell* head )
	{
	int depth = 0;
	while ( head )
		{
		switch( head->type )
			{
			case LIST_START:
				printf("%d LIST_START\n", depth++);
				break;
			case LIST_END:
				printf("%d LIST_END\n", --depth);
				break;
                                                                      
			case BITVECTOR_START:
				printf("%d BITVECTOR_START\n", depth++);
				break;
			case BITVECTOR_END:
				printf("%d BITVECTOR_END\n", --depth);
				break;
                                                                      
			case VECTOR_START:
				printf("%d VECTOR_START\n", depth++);
				break;
			case VECTOR_END:
				printf("%d VECTOR_END\n", --depth);
				break;
                                                                      
			case UNKNOWN_TYPE:
				printf("%d UNKNOWN_TYPE\n", depth);
				break;
			case VOID:
				printf("%d VOID\n", depth);
				break;

			case TYPE_NIL:
				printf("%d TYPE_NIL\n", depth);
				break;
			case TYPE_BOOL:
				printf("%d TYPE_BOOL (%ld)\n", depth,
					head->integer_content);
				break;
			case TYPE_INTEGER:
				printf("%d TYPE_INTEGER (%ld)\n", depth,
					head->integer_content);
				break;
			case TYPE_STRING:
				printf("%d TYPE_STRING (%s)\n", depth,
					head->string_content);
				break;
			case TYPE_DOUBLE:
				printf("%d TYPE_DOUBLE (%f)\n", depth,
					head->double_content);
				break;
			case TYPE_RATIONAL:
				printf("%d TYPE_RATIONAL\n", depth);
				break;
			case TYPE_COMPLEX:
				printf("%d TYPE_COMPLEX\n", depth);
				break;
			case TYPE_SYMBOL:
				printf("%d TYPE_SYMBOL ('%s)\n", depth,
					head->string_content);
				break;
			case TYPE_KEYWORD:
				printf("%d TYPE_KEYWORD (#:%s)\n", depth,
					head->string_content);
				break;
			}
		head = head->next;
		}
	}

static cons_cell* _new_cons_cell()
	{
	cons_cell* cell = malloc( sizeof( cons_cell ) );
	cell->next = 0;
	cell->previous = 0;
	return cell;
	}

static cons_cell* _find_tail( cons_cell* head )
	{
	while ( head->next )
		{
		head = head->next;
		}
	return head;
	}

static cons_cell* _scm_to_cell( SCM scm )
	{
	cons_cell* new = _new_cons_cell();
	new->type = UNKNOWN_TYPE;

	if ( scm_is_bool( scm ) )
		{
		if ( scm_is_false( scm ) )
			{
			// '#nil' is null, bool, false
			//
			if ( scm_is_null( scm ) )
				{
//printf("Nil\n");
				new->type = TYPE_NIL;
				}
			// '#f' is not null, bool, false
			//
			else
				{
//printf("False\n");
				new->type = TYPE_BOOL;
				new->integer_content = 0;
				}
			}
		// '#t' is not null, bool, not false, true
		//
		else
			{
//printf("True\n");
			new->type = TYPE_BOOL;
			new->integer_content = 1;
			}
		}

	else if ( scm_is_true( scm_list_p( scm ) ) )
		{
		// Inconsistency in the API?
		int num_values = scm_to_int( scm_length( scm ) );
		int i;
		cons_cell* tail = new;
		new->type = LIST_START;

//printf("length %d\n",num_values);
		for ( i = 0 ; i < num_values ; i++ )
			{
			// Woops, another weirdness in the API
			SCM _scm = scm_list_ref( scm, scm_from_int( i ) );
			cons_cell* _head = _scm_to_cell( _scm );
			cons_cell* _tail = _find_tail( _head );
			tail->next = _head;
			_head->previous = tail;
			tail = _tail;
			}
		cons_cell* last = _new_cons_cell();
		last->type = LIST_END;
		tail->next = last;
		last->previous = tail;
//printf("list\n");
		}

	// '2' is an integer
	//
	else if ( scm_is_integer( scm ) )
		{
//printf("Integer\n");
		new->type = TYPE_INTEGER;
		new->integer_content = scm_to_int( scm );
		}

	// '""' is an string
	//
	else if ( scm_is_string( scm ) )
		{
//printf("String\n");
		new->type = TYPE_STRING;
		new->string_content = scm_to_locale_string( scm );
		}

	// "'a" is an symbol
	//
	else if ( scm_is_symbol( scm ) )
		{
//printf("Symbol '%s'\n", scm_to_locale_string( scm_symbol_to_string( scm ) ) );
		new->type = TYPE_SYMBOL;
		new->string_content =
			scm_to_locale_string( scm_symbol_to_string( scm ) );
		}

	// '#:a" is an keyword
	//
	else if ( scm_is_keyword( scm ) )
		{
//printf("keyword\n");
		new->type = TYPE_KEYWORD;
		new->string_content =
			scm_to_locale_string( scm_symbol_to_string( scm_keyword_to_symbol( scm ) ) );
		}

	// '-1/2' is a rational (and complex, so test before complex)
	//
	else if ( scm_is_rational( scm ) )
		{
//printf("rational\n");
		new->type = TYPE_RATIONAL;
		new->rational_content.numerator_part =
			scm_to_double( scm_numerator( scm ) );
		new->rational_content.denominator_part =
			 scm_to_double( scm_denominator( scm ) );
		}

	// '-1.2' is a real
	//
	else if ( scm_is_real( scm ) )
		{
//printf("Real\n");
		new->type = TYPE_DOUBLE;
		new->double_content = scm_to_double( scm );
		}

	// '-1i+2' is a complex
	//
	else if ( scm_is_complex( scm ) )
		{
//printf("complex\n");
		new->type = TYPE_COMPLEX;
		new->complex_content.real_part =
			scm_c_real_part( scm );
		new->complex_content.imag_part =
			 scm_c_imag_part( scm );
		}

	// '#*011' is a bitvector
	//
	else if ( scm_is_bitvector( scm ) )
		{
		int i;
		cons_cell* tail = new;
		new->type = BITVECTOR_START;

		for ( i = 0 ; i < scm_c_bitvector_length( scm ) ; i++ )
			{
			SCM _scm = scm_c_bitvector_ref( scm, i );
			cons_cell* _head = _scm_to_cell( _scm );
			cons_cell* _tail = _find_tail( _head );
			tail->next = _head;
			_head->previous = tail;
			tail = _tail;
			}
		cons_cell* last = _new_cons_cell();
		last->type = BITVECTOR_END;
		tail->next = last;
		last->previous = tail;
//printf("bitvector\n");
		}


	// '#(1 2 3)' is a vector, remember it can include other things.
	//
	else if ( scm_is_vector( scm ) )
		{
		int i;
		cons_cell* tail = new;
		new->type = VECTOR_START;

		for ( i = 0 ; i < scm_c_vector_length( scm ) ; i++ )
			{
			SCM _scm = scm_c_vector_ref( scm, i );
			cons_cell* _head = _scm_to_cell( _scm );
			cons_cell* _tail = _find_tail( _head );
			tail->next = _head;
			_head->previous = tail;
			tail = _tail;
			}
		cons_cell* last = _new_cons_cell();
		last->type = VECTOR_END;
		tail->next = last;
		last->previous = tail;
//printf("vector\n");
		}

	// '' is true and only 1 value, apparently.
	//
	else if ( scm_is_true( scm ) )
		{
//printf("Void (fallback)\n");
		new->type = VOID;
		}
//printf("Final type: %d\n", new->type);
	return new;
	}

cons_cell* _run_values( SCM response )
	{
	int i;
	SCM first = scm_c_value_ref( response, 0 );
	cons_cell* head = _scm_to_cell( first );
	cons_cell* tail = _find_tail( head );

	for ( i = 1 ; i < scm_c_nvalues( response ) ; i++ )
		{
		SCM scm = scm_c_value_ref( response, i );
		cons_cell* _head = _scm_to_cell( scm );
		cons_cell* _tail = _find_tail( _head );
		tail->next = _head;
		_head->previous = tail;
		tail = _tail;
		}
	return head;
	}

void* _run( void* expression )
	{
	SCM str = scm_from_utf8_string( (char*) expression );
	SCM response = scm_eval_string( str );
	cons_cell* head;

	// Sigh, special-case void lists.
	if ( scm_c_nvalues( response ) == 0 )
		{
		head = _new_cons_cell();
		head->type = VOID;
		}
	else
		{
		head = _run_values( response );
		}

	return head;
	}

void* __dump( void* _expression )
	{
	char* expression = (char*) _expression;
	SCM str = scm_from_utf8_string( expression );
	SCM scm = scm_eval_string( str );

	printf("SCM object from '%s' returns %d cells\n",
		expression,
		(int)scm_c_nvalues( scm ));
	dump_scm( scm );
	printf("SCM 0th cell\n");
	dump_scm( scm_c_value_ref( scm, 0 ) );

	return expression;
	}

void _dump( const char* expression )
	{
	(void)scm_with_guile( __dump, (void*)expression );
	}

void run( const char* expression, void (*unmarshal(void*)) )
	{
	cons_cell* head = scm_with_guile( _run, (void*)expression );

//_display_list(head);
	while( head )
		{
		unmarshal(head);
		head = head->next;
		}
	}
