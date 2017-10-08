
#include <stdio.h> 
#include <string.h> 
#include <stdlib.h>

#ifndef ALTER
#define ALTER 0
#endif

#ifndef VERBOSE
#define VERBOSE 0
#endif

int main(void) {
  printf("Hello World\n");

  return 0;

} 

void hello(int opt) {  printf("Hello World: int test %d \n", opt); }


long int read_buffer(int opt, void *ptr, size_t *len) {
    
         
  switch (opt) {
    case 0: { 
#if VERBOSE	
	    printf("0: Hello World : This Message   [int64] = %lu \n", sizeof(int64_t)); 
	    printf("1: Hello World : sizeof(int) = %lu \n", sizeof(int)); 
	    printf("2: Hello World : sizeof( long int) = %lu \n", sizeof(long int)); 
	    printf("3: Hello World : null termiated strings \n"); 
	    printf("4: Hello World : printable data \n"); 
	    printf("5: Hello World : binary -> file  \n"); 
#endif
	    return 0;
    }
    case 1: { 
	int *n = (int *)ptr;
#if VERBOSE	
	printf("buffer as int %d sz=%lu\n", *n, *len);  
	printf("buffer as int %d sz=%lu, changing to 60 \n", *n, *len);  
#endif
#if ALTER
	*n = 60;
#endif
	return *n;
	}
    case 2: { 
	long int *n = (long int *)ptr;
#if VERBOSE	
	printf("buffer as int %lu sz=%lu, changing to 700 \n",  *n, *len);  
	printf("buffer as int %lu sz=%lu\n",  *n, *len);  
#endif
#if ALTER
	*n = 700;
#endif
	return *n;
	}
    case 3: { 
	char *s = (char *)ptr;
#if VERBOSE	
	printf("buffer (string) as string:**%s**\n", s);  
#endif
	return strlen(s);
	}
    case 4: {
	char *b = (char *)ptr;
	char *s = (char *)malloc(*len + 1);
	memcpy(s, b, *len);
	s[*len] = '\0';
#if VERBOSE	
	printf("buffer (printable) as string:**%s**\n", s);
#endif
	return *len + 1;

    }
    case 5: {
	char *b = (char *)ptr;
	FILE *h = fopen( "dump", "w" );
	int i;
	for (i = 0; i < *len; ++i)
	    fputc(b[i], h);
	fclose(h);
#if VERBOSE	
	printf("buffer (binary ) dumped to file dump, length = %lu\n", *len);
#endif
	return *len;
    }

  }
  return 0;
}
