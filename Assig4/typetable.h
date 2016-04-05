#ifndef TYPETABLE_H
#define TYPETABLE_H
#include <stdio.h>
#include "hashtable.h"
#include "common.h"
#include <stdlib.h>

/** Type table varible */
entry_t **typetab;


//// TODO: REFACTOR!!!! ////
//This structere used to create a linked list of field names and types
// for structures and unions
/*
typedef struct struct_field_t {
  type_enum f_type;
  char f_name[ID_SIZ];
  struct struct_field_t *next;
} struct_field;
struct_field *create_field(char *name, type_enum type);
*/

//Type information code below
typedef struct typetab_entry {
    char name[ID_SIZ];
    type_enum type;
    enum {
        NONE, STRUCT_T, TYPEDEF_T, FIELD_T
    } kind;
    //points to the next field in a linked list of struct_field objects
    typetab_entry *next;
} typetab_entry;


/** Initialize type table: shall be called before using type table */
void init_typetab();

/** Insert a new typedef type 
 * @param type_name     the name of the typedef type name
 * @param _t            the real type of this aliased type
 * @return              a pointer to the type table entry if successful, 
 *                      and NULL otherwise.
 * */
typetab_entry *insert_typedef(char *type_name, type_enum _t);

/** Insert a new composed structure type. Fields of structure can be added 
 * using insert_struct function.
 * @param struct_name   the name of the structure to declare
 * @return              a pointer to the type table entry if successful,
 *                      or NULL in case of collision
 * @see                 insert_struct
 */
typetab_entry *insert_struct(char *struct_name);

/** Insert a new composed structure type. Fields of structure can be added 
 * using insert_struct function.
 * @param struct_name   the name of the structure in which the field belongs
 * @param field_name    the name of the field to declare as a member of the 
 *                      structure specified above
 * @param field_type    the type of the member variable.
 * @return              a pointer to the type table entry (field), or null
 *                      either when the structure cannot be found or when
 *                      there is a collision in the name of the fields.
 * @see                 insert_struct
 */
typetab_entry *insert_field(char *struct_name, char *field_name, 
        type_enum field_type);

/** @return true if type exists*/
bool is_type_exists(char* type);

//Should be called only if is_type_exists returns true for the given type
//returns INT_TY by default in case the passed type argument was not 
//found in the type table
type_enum get_type(char *type); 

//TODO: refactor
typetab_entry *get_type_obj(char *);


#endif
