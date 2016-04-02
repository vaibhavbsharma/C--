#include "common.h"

char* myitoa(int i) {
    char *retval = malloc(sizeof(char) * SYMTAB_KEY_SIZ);
    sprintf(retval, "%d", i);
    return retval;
}

