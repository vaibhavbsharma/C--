#include "common.h"
#include <stdlib.h>

char* myitoa(int i) {
    char *retval = malloc(sizeof(char) * SYMTAB_KEY_SIZ);
    sprintf(retval, "%d", i);
    return retval;
}

char* gen_key(char *name, int scope) {
    /* note: the length of the string returned by `myitoa(scope)` is 
     * common.h::SYMTAB_KEY_SIZ (260) */
    return strcat(myitoa(scope), name);
}

