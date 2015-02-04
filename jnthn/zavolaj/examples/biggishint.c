/* biggishint.c */
/* Biggish integers in this library are arrays of up 32766 16-bit */
/* (unsigned short) integers for arbitrary precision integer */
/* arithmetic up to 524240-bit (16*32765 bit) numbers.  A biggish */
/* rational library (biggishrat) using these is also being developed. */

/* The data format for these (fairly) big integers is an array of  */
/* short ints allocated on the heap, with the following layout: */
/* +--------------------------------+-------------------------------+ */
/* |     required (2 short ints)    |  optional (up to 16382 times) | */
/* |    word 0       |    word 1    |    word 2     |    word 3 etc | */
/* | 14 bits: size   | 16 bits: int | 16 bits: int  | 16 bits: int  | */
/* | 1 bit: overflow |              |               |               | */
/* | 1 bit: sign     |              |               |               | */
/* +-----------------+--------------+---------------+---------------+ */
/* Word 0 uses 14 bits for the size in units of pairs of short ints, */
/* 1 bit for overflow/underflow and 1 bit for (minus) sign. */
/* The remaining words are all unsigned short integers, always an odd */
/* number of them because of word 0 and the even array size.  Thus */
/* memory allocation occurs in multiples of 4 bytes, a nice alignment */
/* compromise between small and large processor types. */

/* The most compact biggishint uses 4 bytes to count from -65536 to */
/* +65535, the next size (8 bytes) spans -281474976710656 (-2^48) to */
/* +281474976710655 (+2^48-1), and so on to the largest (65532 bytes) */
/* calculating from about -9.22e157811 (-2^524240) to about */
/* +9.22e157811 (+2^524240-1). */

/* The word order is big endian, no matter what the byte order of the */
/* processor may be.  There is no reason for this, it just is. */
/* Update: there is a reason to be little endian: the trim() and */
/* shortmultiply() would improve. */

/* All words are unsigned.  Negative numbers are stored as positive */
/* numbers and the first word keeps a sign bit.  Thus the functions */
/* behave as if each word is simply a digit in a base-65536 number. */
/* The design would use 32-bit words (base-4294967296 numbers) */
/* instead if every possible C compiler had a 64-bit data type to do */
/* carries, but this is not the case. */

/* Functions set the overflow bit if the result does not fit in 32766 */
/* words (including the initial size word).  If the overflow bit is */
/* set the other fields change their meaning: */
/* * The sign bit indicates positive overflow or negative overflow. */
/* * The integer value is unusable, and is therefore reduced to the */
/*   minimum of 1 word.  A design in which the value might represent */
/*   positive or negative infinity (as opposed to mere overflow), */
/*   or other forms of NaN (Not a Number) is under consideration. */

/* Use biggishint at your risk and without warranty.  Give due credit */
/* if you do.  Written by Martin Berends. */

/* See also: a much bigger library: http://gmplib.org/manual/ */
/* Donald E. Knuth The Art of Computer Programming Vol 2 */

/* TODO: overflow detection */
/* TODO: change from big endian to little endian */

#include <assert.h>  /* assert */
#include <ctype.h>   /* tolower */
#include <limits.h>  /* USHRT_MAX */
#include <stdio.h>   /* printf, only when debugging */
#include <stdlib.h>  /* calloc malloc realloc free */
#include <string.h>  /* strlen strncmp */
#include "biggishint.h"  /* (all externally callable functions) */

#if USHRT_MAX != 65535
#error In this C compiler a short int is not a 16 bit number.
#endif

/* #define BIGGISHINT_TRACE */

/* Internal functions are declared here, their definitions are lower */
/* down. */
unsigned short * biggishint_internal_addsubtract(unsigned short * bi1, unsigned short * bi2, int flipsign2);
int              biggishint_internal_bitsize(unsigned long);
unsigned short * biggishint_internal_clone(unsigned short * bi1);
int              biggishint_internal_comparemagnitude(unsigned short * bi1, unsigned short * bi2);
unsigned short * biggishint_internal_shiftleft(unsigned short * bi1, unsigned int bitcount);
unsigned short * biggishint_internal_shiftright(unsigned short * bi1, unsigned int bitcount);
void             biggishint_internal_shortdivide(unsigned short * bi1, unsigned short * i2);
void             biggishint_internal_shortmultiply(unsigned short ** bi1, unsigned short i2);
unsigned short * biggishint_internal_trim(unsigned short ** bi1);


/* --------------------------- Functions ---------------------------- */


/* biggishintAdd */
unsigned short *
biggishintAdd(unsigned short * bi1, unsigned short * bi2)
{
    return biggishint_internal_addsubtract(bi1, bi2, 0);
}


/* biggishintCompare */
int
biggishintCompare(unsigned short * bi1, unsigned short * bi2)
{
    int sign1, sign2, result;
    sign1 = * bi1 & 1;
    sign2 = * bi2 & 1;
    result = sign1
      ? ( sign2 ? biggishint_internal_comparemagnitude(bi2, bi1) : -1 )
      : (!sign2 ? biggishint_internal_comparemagnitude(bi1, bi2) :  1 );
    return result;
}


/* biggishintDivide */
/* see The Art of Computer Programming Vol 2 3rd Ed p270-275 */
unsigned short *
biggishintDivide(unsigned short * bi1, unsigned short * divisor)
{
    /* Before starting on the main long division, which is slow, try */
    /* to identify divisors that offer an opportunity for a shortcut, */
    /* for example shifting right for divisors that are powers of two */
    /* or short division for divisors that fit into a small int. */
    /* In contast with most of the other routines, this one uses */
    /* multiple returns to avoid having many levels of nested */
    /* conditionals. */
    unsigned short   bi1size, divisorsize, dividendword1, dividendword2;
    unsigned short * dividend, * pdividend, * pdividendhi, * pdividendlo;
    unsigned short * quotient, * pquotient, * pquotienthi, * pquotientlo;
    unsigned short * pdivisor, * pdivisorhi, * pdivisorlo;
    int sign1, sign2, sign, comparison, divisorshift;
    unsigned long dividendcarry, trialdivisor;
    unsigned long tempquotient, trialquotientmin, quotientcarry;
    bi1size     = (* bi1 & 0xfffc) >> 1;
    divisorsize = (* divisor & 0xfffc) >> 1;
    sign1 = * bi1 & 1;
    sign2 = * divisor & 1;
    sign  = sign1 ^ sign2;
    /* Does dividend have fewer words than divisor? */
    if (bi1size < divisorsize) {  /* quotient becomes 0 */
        quotient = (unsigned short *) calloc(2, sizeof(short));
        * quotient = 4;
        return quotient;
    }
    /* Is divisor only a 16 bit unsigned number? */
    if (divisorsize == 2) { /* use short division instead of long */
        unsigned short shortdivisor = divisor[1];
        quotient = biggishint_internal_clone(bi1);
        biggishint_internal_shortdivide(quotient, & shortdivisor);
        * quotient ^= sign2;
        return biggishint_internal_trim(&quotient);
    }
    /* Is dividend less in magnitude than divisor? */
    comparison = biggishint_internal_comparemagnitude(bi1, divisor);
    if (comparison<0) {  /* quotient becomes 0 */
        /* Hope the C compiler merges this code with the same code in */
        /* (bi1size < bi2size) above.  Repeated here because the */
        /* earlier case avoids the comparemagnitude function. */
        quotient = (unsigned short *) calloc(2, sizeof(short));
        * quotient = 4;
        return quotient;
    }
    /* Is dividend equal in magnitude to divisor? */
    if (comparison==0) {  /* quotient becomes 1 (+ or -) */
        quotient = (unsigned short *) calloc(2, sizeof(short));
        * quotient = 4 | sign;
        quotient[1] = 1;
        return quotient;
    }
    /* Is divisor a power of two or a multiple of a power of two? */
    /* ie is there only a single 1 bit or at least one trailing 0 bit? */
    if (0) {
        ;    /* TODO: right shift optimization */
    }
    /* Perform long division because none of the quicker algorithms */
    /* above could be used with the given parameters. */
    assert( bi1size >= 4 ); assert( divisorsize >= 4 );
    /* Initialize dividend with bi1.  The loop below will repeatedly */
    /* subtract multiples of divisorshifted until the remainder is */
    /* less than divisor. */
    dividend = biggishint_internal_clone(bi1);
    pdividendhi = dividend + (dividend[1] ? 1 : 2);
    pdividendlo = dividend + bi1size - 1;
    #ifdef BIGGISHINT_TRACE
        fprintf(stdout,"dividend %s%04x", (* dividend & 1)?"-":"",
            * (pdividend=pdividendhi));
        while (++pdividend <= pdividendlo)
            fprintf(stdout,"_%04x", * pdividend);
        fprintf(stdout," at %p hi %+ld lo %+ld\n",
            dividend, pdividendhi-dividend, pdividendlo-dividend);
    #endif
    /* Point to the divisor's highest and lowest data words */
    pdivisorhi = divisor + (divisor[1] ? 1 : 2);
    pdivisorlo = divisor + divisorsize - 1;
    trialdivisor = (unsigned long) (* pdivisorhi) + 1;
    #ifdef BIGGISHINT_TRACE
        fprintf(stdout,"divisor  %s%04x", (* divisor & 1)?"-":"",
            * (pdivisor=pdivisorhi));
        while (++pdivisor <= pdivisorlo)
            fprintf(stdout,"_%04x", * pdivisor);
        fprintf(stdout," at %p hi %+ld lo %+ld\n",
            divisor, pdivisorhi-divisor, pdivisorlo-divisor);
    #endif
    /* Initialize the quotient (result)  */
    quotient = (unsigned short *) calloc(bi1size, sizeof(short));
    * quotient = bi1size << 1 | sign;
    /* Work out at which word in quotient the result will begin */
    pquotienthi = quotient + (bi1[1] ? 1 : 2) + (pdivisorlo-pdivisorhi);
    pquotientlo = quotient + bi1size - 1;
    dividendcarry = 0;
    /* Calculate one word of the quotient per loop */
    while (pquotienthi<=pquotientlo) {
        /* To avoid comparing all the words of the divisor, perform a */
        /* trial division of dividendcarry by the first word of the */
        /* divisor plus one. */
        dividendcarry += * pdividendhi;
        trialquotientmin = dividendcarry / trialdivisor;
        while (trialquotientmin) {
            #ifdef BIGGISHINT_TRACE
                fprintf(stdout,"carry(%ld) %x dividendcarry %lx/%lx=%lx\n",
                    pdividendhi-dividend, * pdividendhi, dividendcarry,
                    trialdivisor, trialquotientmin);
                fprintf(stdout,"  quotient %s%04x", (* quotient & 1)?"-":"",
                    * (pquotient=quotient));
                while (++pquotient <= pquotientlo)
                    fprintf(stdout,"_%04x", * pquotient);
                fprintf(stdout," at %p hi %+ld lo %+ld\n",
                    quotient, pquotienthi-quotient, pquotientlo-quotient);
            #endif

            /* Subtract shifted trialquotient*divisor from dividend. */
            tempquotient = trialquotientmin;
            divisorshift = 0;
            while (tempquotient) {
                pdividend = pdividendhi + (pdivisorlo - pdivisorhi) - divisorshift++;
                #ifdef BIGGISHINT_TRACE
                    fprintf(stdout,"    tempquotient %lx pdividend %+ld\n",
                        tempquotient, pdividend-dividend);
                #endif
                /* Use tempquotient1 to subtract successive words of */
                /* divisor multiplied by tempquotient2 from dividend. */
                quotientcarry = 0UL;
                for (pdivisor=pdivisorlo; pdivisor>=pdivisorhi; --pdivisor) {
                    quotientcarry += (* pdivisor) * (tempquotient & 0xffff);
                    dividendword1 = (* pdividend);
                    dividendword2 = quotientcarry & 0xffff;
                    #ifdef BIGGISHINT_TRACE
                        fprintf(stdout,"      dividend[%ld] = %04x-%04x = ",
                            pdividend-dividend, dividendword1, dividendword2);
                    #endif
                    if (dividendword1 >= dividendword2)  /* just subtract */
                        dividendword1 -= dividendword2;
                    else {                       /* borrow, then subtract */
                        dividendword1   = 0x10000UL + dividendword1 - dividendword2;
                        quotientcarry += 0x10000UL;
                    }
                    #ifdef BIGGISHINT_TRACE
                        fprintf(stdout,"%04x tempquotient1 %lx\n",
                             dividendword1, quotientcarry);
                    #endif
                    * pdividend-- = dividendword1;
                    quotientcarry>>=16;
                }
                assert( quotientcarry <= 0xffff ); /* no loop required */
                if (quotientcarry) {
                    #ifdef BIGGISHINT_TRACE
                        fprintf(stdout,"      dividend[%ld] = %04x-%04lx = ",
                            pdividend-dividend, * pdividend, quotientcarry);
                    #endif
                    (* pdividend) -= (unsigned short) quotientcarry;
                    #ifdef BIGGISHINT_TRACE
                        fprintf(stdout,"%04x\n", * pdividend);
                    #endif
                }
                tempquotient >>= 16;
            } /* Subtracting shifted trialquotient*divisor from dividend */

            /* Add shifted trialquotient to quotient */
            tempquotient = trialquotientmin;
            pquotient = pquotienthi;
            while (tempquotient) {
                tempquotient += * pquotient;
                * pquotient-- = tempquotient & 0xffff;
                tempquotient >>= 16;
            }

            /* Make a new dividendcarry from dividend. */
            /* TODO: use assert() to check whether a loop is really needed */
            dividendcarry = 0;
            for (pdividend=dividend+1; pdividend<=pdividendhi; ++pdividend ) {
                dividendcarry = (dividendcarry<<16) + (* pdividend);
            }
            trialquotientmin = dividendcarry / trialdivisor;
        }  /* while (trialquotientmin > 0) */

        #ifdef BIGGISHINT_TRACE
        fprintf(stdout,"  dividend %s%04x", (* dividend & 1)?"-":"",
            * (pdividend=dividend));
        while (++pdividend <= pdividendlo)
            fprintf(stdout,"_%04x", * pdividend);
        fprintf(stdout," at %p hi %+ld lo %+ld\n",
            dividend, pdividendhi-dividend, pdividendlo-dividend);
        #endif

        /* Proceed to the next word in the quotient and dividend */
        dividendcarry <<= 16;
        ++pquotienthi;
        ++pdividendhi;
    }

    #ifdef BIGGISHINT_TRACE
    fprintf(stdout,"  quotient %s%04x", (* quotient & 1)?"-":"",
        * (pquotient=quotient));
    while (++pquotient <= pquotientlo)
        fprintf(stdout,"_%04x", * pquotient);
    fprintf(stdout," at %p hi %+ld lo %+ld\n",
        quotient, pquotienthi-quotient, pquotientlo-quotient);
    #endif

    /* Subtract (trialquotient2*divisor) from dividend. */
    pdividend = pdividendlo;
    #ifdef BIGGISHINT_TRACE
    fprintf(stdout,"    trialquotientmin %lx pdividend %+ld\n",
        trialquotientmin, pdividend-dividend);
    #endif
    /* Try to subtract the divisor from the dividend (this is the */
    /* only time divisor is used instead of leading word of divisor */
    /* + 1. */
    dividendcarry = 0;
    while (biggishint_internal_comparemagnitude(dividend, divisor) >= 0) {
        pdividend = pdividendlo;
        dividendword2 = 0;  /* used as the borrow word in subtraction */
        for (pdivisor=pdivisorlo; pdivisor>=pdivisorhi; --pdivisor) {
            dividendword1 = * pdividend;
            if ((unsigned long) dividendword1 >= (unsigned long) * pdivisor + dividendword2) {
                /* just subtract */
                dividendword1 -= * pdivisor + dividendword2;
                dividendword2 = 0;
            }
            else {  /* borrow, then subtract */
                dividendword1 = (unsigned long) dividendword1 - * pdivisor + dividendword2;
                dividendword2 = 1;
            }
            * pdividend-- = dividendword1;
        }
//      unsigned short * dividend_temp = dividend;
//      dividend = biggishint_internal_addsubtract(dividend_temp, divisor, 1);
//      free(dividend_temp);
        ++dividendcarry;
    }
    #ifdef BIGGISHINT_TRACE
    fprintf(stdout,"final dividendcarry %lx\n", dividendcarry);
    #endif
    assert( dividendcarry <= 1 );
    pquotient = pquotientlo;
    while (dividendcarry && (pquotient>quotient)){
        dividendcarry += * pquotient;
        * pquotient-- = dividendcarry & 0xffff;
        dividendcarry >>= 16;
    }

    free(dividend);
    return biggishint_internal_trim(&quotient);
}


/* biggishintFree */
void
biggishintFree(unsigned short * bi1)
{
    free(bi1);
}


/* biggishintFromDecimalString */
/* Note: this algorithm is unacceptably inefficient and should be */
/* rewritten, because the two other biggishint functions it calls */
/* cause two malloc() calls per decimal digit. */
unsigned short *
biggishintFromDecimalString(char * str)
{
    char * ps, c;
    int sign = 0;
    unsigned short * bi1, * bi2;
    unsigned short digitvalue[2] = {4,0};
    ps = str;
    if (* ps == '-') { /* Detect a leading minus sign */
        sign = 1;
        ++ps;
    }
    /* Create the initial biggishint result with a value of 0 */
    bi1 = (unsigned short *) calloc(2,2);
    * bi1 = 4 | sign;
    /* take one digit at a time, convert to binary, accumulate values */
    while ( isdigit(c = * ps++) ) {
        biggishint_internal_shortmultiply(&bi1, 10);
        digitvalue[1] = c - '0';
        bi2 = biggishint_internal_addsubtract(bi1, digitvalue, 0);
        free(bi1);
        bi1 = bi2;
    }
    return bi1;
}


/* biggishintFromHexadecimalString */
unsigned short *
biggishintFromHexadecimalString(char * str)
{
    int hexdigitcount, biggishintwordcount, i, nybble, sign=0;
    unsigned short biggishintarraysize, * biggishint, * shortPointer, value;
    char character, * strPointer;

    strPointer = str;
    if (* strPointer == '-') { /* Detect a leading minus sign */
        sign = 1;
        ++strPointer;
    }
    if (strncmp(strPointer, "0x", 2) == 0) /* skip the '0x' prefix if it exists */
        strPointer += 2;
    hexdigitcount = strlen(strPointer);
    /* The number of short integers holding values must always be odd */
    biggishintwordcount = (((hexdigitcount+3)>>3)<<1)+1; /* 1-4=>1, 5-12=>3 etc */
    biggishintarraysize = biggishintwordcount + 1;
    biggishint = (unsigned short *) calloc(biggishintarraysize, sizeof(unsigned short));
    assert( biggishint != NULL );
    shortPointer = biggishint;
    * shortPointer++ = (biggishintarraysize << 1) | sign;
    /* leave one word blank for 5-8 13-16 21-24 digit strings */
    if ( (hexdigitcount-1) & 0x4) ++shortPointer;
    value = 0;
    for (i=hexdigitcount-1; i>=0; --i) { 
        character = tolower(* strPointer++);
        nybble = character - '0' - (character>='a' ? 'a'-'9'-1 : 0);
        value = (value<<4) + nybble;
        if ((i%4) == 0) {
            * shortPointer++ = value;
            value = 0;
        }
    }
    return biggishint;
}


/* biggishintFromLong */
unsigned short *
biggishintFromLong(long l)
{
    unsigned short * bi1, negative_bit=0;
    if (l<0) {
        negative_bit = 1;
        l = -l;
    }
    if (l <= USHRT_MAX) {
        bi1 = (unsigned short *) calloc(2,sizeof(short));
        * bi1 = 4 | negative_bit;
        bi1[1] = (unsigned short) l;
    }
    else {
        bi1 = (unsigned short *) calloc(4,sizeof(short));
        * bi1 = 8 | negative_bit;
        bi1[3] = (unsigned short) l;
        bi1[2] = l >> 16;
    }
    return bi1;
}


/* biggishintMultiply */
unsigned short *
biggishintMultiply(unsigned short * bi1, unsigned short * bi2)
{
    unsigned short bi1size, bi2size, res1size, res2size, sign1, sign2;
    unsigned short * p1, * p2, * result, * presult;
    int i1, i2;
    unsigned long resultsize, n1, n2, subtotal, carry;

    /* Before starting on the main long multiplication, which is */
    /* slow, try to identify multipliers that offer an opportunity */
    /* for a shortcut, for example by 0 or 1, shifting left for */
    /* multipliers that are multiples of powers of two, or short */
    /* multiplication. */
    bi1size = (* bi1 & 0xfffc) >> 1;
    bi2size = (* bi2 & 0xfffc) >> 1;
    if (bi1size == 2) {
        result = biggishint_internal_clone(bi2);
        * result &= 0xfffe;  /* clear the sign bit */
        biggishint_internal_shortmultiply(&result, bi1[1]);
    }
    else {
        if (bi2size == 2) {
            result = biggishint_internal_clone(bi1);
            * result &= 0xfffe;  /* clear the sign bit */
            biggishint_internal_shortmultiply(&result, bi2[1]);
        }
        else { /* both bi1 and bi2 are more than 16 bit numbers */
            /* Create a result array that is large enough for any */
            /* possible product.  First calculate the smallest size */
            /* according to the contents of bi1 and bi2, regardless */
            /* of the need to round up to an even number. */ 
            res1size = bi1size + (bi1[1] ? 0 : -1); /* the first word may be 0 */
            res2size = bi2size + (bi2[1] ? 0 : -1);
            /* Then add them together and round to an even number */
            resultsize  = (res1size + res2size + 1) & 0xfffe;
            result = (unsigned short *) calloc(resultsize, sizeof(short));
            * result = (resultsize << 1);
            presult = result + resultsize;
            p1 = bi1 + bi1size;
            for (i1=1; i1<bi1size; ++i1) {
                n1 = * --p1;
                presult = result + resultsize - i1;
                p2 = bi2 + bi2size;
                carry = 0;
                for (i2=1; i2<bi2size; ++i2) {
                    n2 = * --p2;
                    subtotal = (* presult) + n1 * n2 + carry;
                    carry = subtotal >> 16;
                    * presult-- = subtotal & 0xffff;
                }
                while (carry) {
                    * presult-- = carry;
                    carry >>= 16;
                }
            }
        }
    }
    sign1 = * bi1 & 1;
    sign2 = * bi2 & 1;
    * result |= sign1 ^ sign2;
    return biggishint_internal_trim(&result);
}


/* biggishintShiftLeft */
unsigned short *
biggishintShiftLeft(unsigned short * bi1, unsigned short * bi2)
{   /* TODO: shift counts from 65536 to 524239 and -1 to -524239 bits */
    return biggishint_internal_shiftleft(bi1, bi2[1]);
}


unsigned short *
biggishintShiftRight(unsigned short * bi1, unsigned short * bi2)
{
    return NULL;
}


/* biggishintSubtract */
unsigned short *
biggishintSubtract(unsigned short * bi1, unsigned short * bi2)
{
    return biggishint_internal_addsubtract(bi1, bi2, 1);
}


/* biggishintToDecimalString */
char *
biggishintToDecimalString(unsigned short * bi1)
{
    /* The number of decimal digits that will be created is difficult */
    /* (or slow) to calculate in advance.  This routine initially */
    /* over-allocates memory, and then sizes it correctly at the end. */
    unsigned short bi1size, * bi2, digit, sign1;
    int strsize, leadingzeroes;
    char * result, * pdigits, * p1;
    /* Calculate the very maximum number of characters that the */
    /* resulting string can occupy, including a terminating '\0'. */
    /* Each word is '65535' at most, then '\0' */
    bi2 = biggishint_internal_clone(bi1);
    bi1size = (* bi1 & 0xfffc) >> 1;
    sign1 = * bi1 & 1;
    strsize = (bi1size-1) * 5 + sign1 + 1;
    result = (char *) malloc(strsize);
    assert( result != NULL );
    pdigits = result;
    if (sign1) * pdigits++ = '-';
    p1 = result + strsize;
    (* --p1) = '\0';
    do {
        digit = 10;
        biggishint_internal_shortdivide(bi2, &digit);
        (* --p1) = '0' + digit;
    } while ( p1 > pdigits ); /* TODO: find other ways to finish early */
    free(bi2);
    /* Count how many '0' characters there are at the beginning of */
    /* the string, and then move the non '0' characters. */
    leadingzeroes = strspn(pdigits, "0");
    if (leadingzeroes == strsize - sign1 - 1)
        --leadingzeroes;
    if (leadingzeroes) {
        memmove(pdigits, pdigits+leadingzeroes, strsize-sign1-leadingzeroes); /* (Big Endian)-- ;) */
        result = realloc(result, strsize-leadingzeroes);
    }
    return result;
}


/* biggishintToHexadecimalString */
char *
biggishintToHexadecimalString(unsigned short * bi1)
{
    int bi1size, hexstringsize, i, j, value, nybble, emitzero, sign;
    char * hexString, * hexPointer;
    bi1size = (* bi1 & 0xfffc) >> 1;
    sign = * bi1 & 1;
    /* Calculate how many characters the hex string needs, including */
    /* the "0x" at the beginning and a '\0' at the end */
    hexstringsize = (biggishint_internal_bitsize(bi1[1])+3)>>2; /* 0=>0, 1-4=>1, 5-8=>2 */
    hexstringsize += (hexstringsize?0:1) /* allow for 0 digit */
        + 3 + sign + ((bi1size-2) << 2); /* '0x' + sign + digits + '\0' */
    hexString = (char *) malloc(hexstringsize);
    assert( hexString != NULL );
    hexPointer = hexString;
    if (sign) * hexPointer++ = '-';
    * hexPointer++ = '0'; * hexPointer++ = 'x';
    emitzero = 0;  /* do not emit leading zeroes */
    for (i=1; i<bi1size; ++i) {
        value = bi1[i];
        for (j=3; j>=0; --j) {
            nybble = (value >> (j*4)) & 0xf;
            if (nybble || emitzero) {
                * hexPointer++ = '0' + nybble + ((nybble>9) ? 'a'-'9'-1 : 0);
                emitzero = 1;
            }
        }
    }
    if (! emitzero)
        * hexPointer++ = '0';
    * hexPointer = '\0';
    return hexString;
}


/* ----------------------- Internal functions ----------------------- */
/* Except for biggishint_internal_trim, the internal functions do not */
/* trim their results, because it costs time, may be redundant, and */
/* increases heap churn. */


/* biggishint_internal_addsubtract */
unsigned short * biggishint_internal_addsubtract(unsigned short * bi1,
                                    unsigned short * bi2, int flipsign2)
{
    unsigned short bi1size, bi2size, res1size, res2size, resultsize;
    unsigned short * result1, * result2, * larger, * smaller, * p1, * p2;
    unsigned int sign1, sign2, sign, carry, i1, i2;
    signed long partialresult;
    sign1 = * bi1 & 1;
    sign2 = (* bi2 & 1) ^ flipsign2;
    if (sign1 ^ sign2) {  /* different signs, do a subtract */
        /* the larger number determines the size and sign of the result */
        if (biggishint_internal_comparemagnitude(bi1,bi2) >= 0) {
            larger  = bi1; smaller = bi2; sign = sign1;
        }
        else {
            smaller = bi1; larger  = bi2; sign = sign2;
        }
        resultsize = (* larger & 0xfffc) >> 1;
        result1 = (unsigned short *) calloc(resultsize, sizeof(short));
        result2 = result1 + resultsize;
        p1 = larger  + ((* larger  & 0xfffc) >> 1);
        p2 = smaller + ((* smaller & 0xfffc) >> 1);
        carry = 0;
        partialresult = 0;
        while (--p1 > larger) {
            i1 = * p1;
            i2 = (--p2 > smaller) ? * p2 : 0;
            partialresult += i1 - i2;
            * --result2 = (partialresult >=0)
                          ? (unsigned short) partialresult
                          : (unsigned short) (partialresult + 65536);
            partialresult = (partialresult & 0xffff0000) ? -1 : 0;
        }
    }  /* subtract */
    else {  /* same signs, do an add */
        bi1size = (* bi1 & 0xfffc) >> 1;
        bi2size = (* bi2 & 0xfffc) >> 1;
        res1size = bi1size + (bi1[1] ? 1 : 0); /* the first word may be 0 */
        res2size = bi2size + (bi2[1] ? 1 : 0);
        resultsize  = ((res1size > res2size ? res1size : res2size) + 1) & 0xfffe;
        sign = sign1;
        result1 = (unsigned short *) calloc(resultsize, sizeof(short));
        assert( result1 != NULL );
        /* Initialize pointers to the augend (bi1), addend (bi2) and partialresult */
        * result1 = resultsize << 1;
        p1      = bi1 + bi1size - 1;
        p2      = bi2 + bi2size - 1;
        result2 = result1 + resultsize - 1;
        carry = 0;
        /* Iteratively add words from least significant to most */
        while (result2 > result1) {
            i1 = i2 = 0;
            if (p1 > bi1)
                i1 = * p1--;
            if (p2 > bi2)
                i2 = * p2--;
            partialresult = i1 + i2 + carry;
            carry = 0;
            if (partialresult > USHRT_MAX) {
                carry = 1;
                partialresult -= (USHRT_MAX + 1);
            }
            * result2-- = (unsigned short) partialresult;
        }  /* while */
    }  /* add */
    * result1 = (resultsize << 1) | sign;
    return biggishint_internal_trim(&result1);
}

/* biggishint_internal_bitsize */
/* Count how many bits a number uses (0-64), returns 1 + position of first 1 bit */
int
biggishint_internal_bitsize(unsigned long n)
{
    int bitsize = 0;
    for ( ; n; n >>= 1)
        ++bitsize;
    return bitsize;
}


/* biggishint_internal_clone */
unsigned short *
biggishint_internal_clone(unsigned short * bi1)
{
    unsigned short clonebytes, * clone;
    clonebytes = * bi1 & 0xfffffffe;
    clone = (unsigned short *) malloc(clonebytes);
    assert( clone != NULL );
    memcpy(clone, bi1, clonebytes);
    return clone;
}


/* biggishint_internal_comparemagnitude */
/* returns -1 if bi1<bi2, 0 if bi1==bi2, +1 if bi1>bi2 */
int biggishint_internal_comparemagnitude(unsigned short * bi1, unsigned short * bi2)
{
    unsigned short * pi1data, * pi1, * pi2data, * pi2;
    unsigned short i1, i2, bi1size, bi2size, loopcount;
    int result=0;
    /* This function could often be quicker by comparing the sizes of */
    /* the two numbers, but that implies trusting the rest of the */
    /* code to always trim leading zero words where possible.  The */
    /* test suite currently lacks the coverage required to enable */
    /* that trust. */
    bi1size = (* bi1 & 0xfffc) >> 1;
    bi2size = (* bi2 & 0xfffc) >> 1;
    /* the max number of comparisons is max(bi1size,bi2size)-1 */
    loopcount = ((bi1size>bi2size) ? bi1size : bi2size) - 1;
    pi1data = bi1 + 1;
    pi2data = bi2 + 1;
    pi1     = bi1 + bi1size - loopcount;
    pi2     = bi2 + bi2size - loopcount;
    while (result==0 && loopcount--) {
        /* substitute leading zeroes for whichever number is shorter */
        i1 = (pi1<pi1data) ? 0 : * pi1;  ++pi1;
        i2 = (pi2<pi2data) ? 0 : * pi2;  ++pi2;
        /* compare the two words from each biggishint */
        result = (i1<i2) ? -1 : (i1>i2) ? 1 : 0;
    }
    return result;
}

/* biggishint_internal_shiftleft */
unsigned short *
biggishint_internal_shiftleft(unsigned short * bi1, unsigned int bitcount)
{
    unsigned short bi1size, * result, * p1, * p2, carry;
    unsigned int inputbitcount, resultbitcount, resultsize, inputloop;
    unsigned int shiftleft, shiftright, inputword, resultword;
    bi1size = (* bi1 & 0xfffc) >> 1;
    /* Calculate the number of data bits needed for the result */
    inputbitcount = biggishint_internal_bitsize(bi1[1]) + ((bi1size - 2) << 4);
    resultbitcount = inputbitcount + bitcount;
    assert( resultbitcount < 524272);
    /* Calculate the total number of words to allocate for the result */
    resultsize = 1 + ((resultbitcount + 15) >> 4);
    result = (unsigned short *) calloc(resultsize, sizeof(short));
    * result = resultsize << 1;
    /* prepare initial values for the loop below */
    shiftleft  = bitcount & 0xf;
    shiftright = 16 - shiftleft;
    p1 = bi1 + 1;
    p2 = result + 1;
    inputword = * p1++;
    inputloop = bi1size;
    carry = inputword << shiftleft;
    /* Check whether part of the first word of the input needs to */
    /* carry over to the second word of the result */
    if ( ((inputbitcount-1) & 0xf) > ((resultbitcount-1) & 0xf) ) {
        /* Yes, so here store the bits that will not be carried */
        resultword = inputword >> shiftright;
        * p2++ = resultword;
        --inputloop;
    }
    while (--inputloop) {
        inputword = * p1++;
        resultword = carry | (inputword >> shiftright);
        * p2++ = resultword;
        carry = inputword << shiftleft;
    }
    * p2++ = carry;
    return result;
}


/* TODO: biggishint_internal_shiftright */
unsigned short *
biggishint_internal_shiftright(unsigned short * bi1, unsigned int bitcount)
{
    unsigned short bi1size, * result;
    bi1size = 2;
    result = (unsigned short *) malloc(bi1size);
    return result;
}


/* biggishint_internal_shortdivide */
/* Short division only (divisor <= 0xffff). */
/* Returns quotient in (* bi1), remainder in (* i2) */
void
biggishint_internal_shortdivide(unsigned short * bi1, unsigned short * i2)
{
    unsigned short bi1size, * pi1, * pi2, divisor, remainder, hi, lo;
    unsigned long partialdividend, partialquotient;
    bi1size   = (* bi1 & 0xfffc) >> 1;
    divisor   = * i2;
    remainder = 0;
    pi1       = bi1 + 1;
    pi2       = bi1 + bi1size;
    lo        = 0;
    while ( pi1 < pi2 ) {
        hi = lo;
        lo = * pi1;
        partialdividend = ((unsigned long)hi << 16) | lo;
        partialquotient = partialdividend / divisor;
        remainder       = partialdividend % divisor;
        hi = partialquotient & 0xffff;
        lo = remainder;
        * pi1++ = hi;
    }
    * i2 = remainder;
}


/* biggishint_internal_shortmultiply */
void
biggishint_internal_shortmultiply(unsigned short ** bi1, unsigned short multiplier)
{
    unsigned short bi1size, productsize, * product, * pi, * pp;
    unsigned long productcarry;
    if (multiplier == 0) {
        * bi1 = realloc(* bi1, sizeof(short)<<1);
        (* bi1)[0] = 4;  (* bi1)[1] = 0;
    }
    else {
        if (multiplier != 1) {
            /* TODO: avoid realloc if possible */
            bi1size   = (** bi1 & 0xfffc) >> 1;
            productsize = bi1size + 2;  /* even number of words */
            product = (unsigned short *) calloc(productsize, sizeof(short));
            * product = productsize << 1;
            pi = * bi1   + bi1size     - 1;
            pp = product + productsize - 1;
            productcarry = 0;
            do {
                productcarry += (* pi--) * (unsigned int)multiplier;
                (* pp--) = (unsigned short) productcarry;
                productcarry >>= 16;
            } while ( pi > * bi1 );
            assert( productcarry < 0xffffffff );
            while (productcarry) {
                (* pp--) = (unsigned short) productcarry;
                productcarry >>= 16;
            }
            free(* bi1);
            * bi1 = product;
            biggishint_internal_trim(bi1);
        }
    }
}


/*
#include <stdio.h>
    fprintf(stderr,"sign %d\n", sign);
*/


/* biggishint_internal_trim */
/* If possible, remove leading zeroes from the front of the biggishint */
/* Also remove the minus sign from -0 results */
/* Note: it reallocates the data, so it may be at a new address. */
unsigned short *
biggishint_internal_trim(unsigned short ** pbi1)
{
    /* For example, change this: */
    /* +------+------+------+------+------+------+ */
    /* | 000c | 0000 | 0000 | 0000 | 1234 | cdef | */
    /* +------+------+------+------+------+------+ */
    /* to this: */
    /* +------+------+------+------+ */
    /* | 0008 | 0000 | 1234 | cdef | */
    /* +------+------+------+------+ */
    unsigned int sign;
    unsigned short bi1size, newsize;
    unsigned short * bi1, * pLeft, * pSearch, * pRight, * pAfterZeroes;

    bi1 = * pbi1;
    /* Count the number of contiguous leading zero words */
    bi1size      = (* bi1 & 0xfffc) >> 1;
    sign         = * bi1 & 1;
    pLeft        = bi1 + 1;
    pSearch      = bi1;
    pRight       = bi1 + bi1size; /* just outside the biggishint */
    pAfterZeroes = pRight;
    /* Try to set pSearch to the address of the first non zero word. */
    /* After this loop completes, pAfterZeroes either points to the */
    /* first nonzero word, or to the first address after the biggishint. */
    while (++pSearch < pAfterZeroes) /* note pAfterZeroes moves! */
        if ( * pSearch )
            pAfterZeroes = pSearch;
    /* If there are leading words filled with zeroes, move the non */
    /* zero words to the left to overwrite them */
    if (pAfterZeroes > pLeft) {
        newsize = (pRight - pAfterZeroes + 2) & 0xfffe; /* always even */
        if (newsize < bi1size) {
            /* Trim the size of the memory allocation */
            /* Bump the destination by 1 if the first non zero word */
            /* was at an even subscript */
            pLeft += (pAfterZeroes - bi1 + 1) & 1;
            /* If the array was little endian, memmove would not happen */
            memmove(pLeft, pAfterZeroes, (pRight - pAfterZeroes) << 1);
            bi1 = realloc(bi1, newsize << 1);
            * bi1 = (newsize << 1) | sign;
            * pbi1 = bi1;
        }
    }
    /* Convert the silly case of -0 into 0 */
    if (* bi1 == 5 && bi1[1]==0) * bi1 = 4;
    return bi1;
}


/* end of biggishint.c */
