#ifndef UTIL_H_
#define UTIL_H_

/** a pseudo-itoa that converts an integer to string 
* @param i    an integer to convert
* @return     the integer converted to string
* */
char* itoa(int i) {
  char *retval = malloc(sizeof(char)*100);
  sprintf(retval,"%d",i);
  return retval;
}

#endif
