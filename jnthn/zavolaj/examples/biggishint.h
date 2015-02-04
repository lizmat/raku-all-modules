/* biggishint.h */

/* Commented out entries are NYI */
unsigned short * biggishintAdd                   (unsigned short * biggishint1, unsigned short * biggishint2);
//unsigned short * biggishintBitwiseAnd            (unsigned short * biggishint1, unsigned short * biggishint2);
//unsigned short * biggishintBitwiseNot            (unsigned short * biggishint);
//unsigned short * biggishintBitwiseOr             (unsigned short * biggishint1, unsigned short * biggishint2);
//unsigned short * biggishintBitwiseXor            (unsigned short * biggishint1, unsigned short * biggishint2);
//unsigned short * biggishintBooleanAnd            (unsigned short * biggishint1, unsigned short * biggishint2);
//unsigned short * biggishintBooleanNot            (unsigned short * biggishint);
//unsigned short * biggishintBooleanOr             (unsigned short * biggishint1, unsigned short * biggishint2);
//unsigned short * biggishintBooleanXor            (unsigned short * biggishint1, unsigned short * biggishint2);
int              biggishintCompare               (unsigned short * biggishint1, unsigned short * biggishint2);
//void             biggishintDecrement             (unsigned short * biggishint);
unsigned short * biggishintDivide                (unsigned short * biggishint1, unsigned short * biggishint2);
void             biggishintFree                  (unsigned short * biggishint1);
unsigned short * biggishintFromDecimalString     (char * str);
unsigned short * biggishintFromHexadecimalString (char * str);
unsigned short * biggishintFromLong              (long l);
//void             biggishintIncrement             (unsigned short * biggishint);
//unsigned short * biggishintModulo                (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintMultiply              (unsigned short * biggishint1, unsigned short * biggishint2);
//unsigned short * biggishintPower                 (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintShiftLeft             (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintShiftRight            (unsigned short * biggishint1, unsigned short * biggishint2);
unsigned short * biggishintSubtract              (unsigned short * biggishint1, unsigned short * biggishint2);
char           * biggishintToDecimalString       (unsigned short * biggishint);
char           * biggishintToHexadecimalString   (unsigned short * biggishint);
/*                                               ^ no, you can't do this in Perl 6! */
/* end of biggishint.h */
