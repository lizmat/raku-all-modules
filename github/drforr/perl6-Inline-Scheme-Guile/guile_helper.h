typedef enum
	{
	LIST_START      = -260,
	LIST_END        = -259,

	BITVECTOR_START = -258,
	BITVECTOR_END   = -257,

	VECTOR_START    = -256,
	VECTOR_END      = -255,
                       
	UNKNOWN_TYPE    = -2,
	VOID            = -1,
                       
	TYPE_NIL        = 1, // Yes, redundant, but matching the Perl...
	TYPE_BOOL       = 2,
	TYPE_INTEGER    = 3,
	TYPE_STRING     = 4,
	TYPE_DOUBLE     = 5,
	TYPE_RATIONAL   = 6,
	TYPE_COMPLEX    = 7,
	TYPE_SYMBOL     = 8,
	TYPE_KEYWORD    = 9,
	}
	cons_cell_type;

typedef struct
	{
	double real_part;
	double imag_part;
	}
	complex_value;

typedef struct
	{
	double numerator_part;
	double denominator_part;
	}
	rational_value;

typedef struct cons_cell cons_cell;
struct cons_cell
	{
	cons_cell_type type;
	union
		{
		long           integer_content;
		char*          string_content;
		double         double_content;
		rational_value rational_content;
		complex_value  complex_content;
		};
	cons_cell* next;
	cons_cell* previous;
	};
