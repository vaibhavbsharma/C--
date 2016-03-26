#ifndef COMMON_H_
#define COMMON_H_


/** a pseudo-itoa that converts an integer to string 
* @param i    an integer to convert
* @return     the integer converted to string
* */
char* myitoa(int i);


#ifdef DEBUG
#include <stdio.h>
#include <stdlib.h>

#define debug(M, ...) fprintf(stderr, "DEBUG %s:%d: " M "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#else
#define debug(M, ...)
#endif


#endif
