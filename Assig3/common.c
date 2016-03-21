#include "common.h"

char* myitoa(int i) {
  char *retval = malloc(sizeof(char)*100);
  sprintf(retval,"%d",i);
  return retval;
}

