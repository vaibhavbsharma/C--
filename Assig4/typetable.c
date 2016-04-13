#include "typetable.h"

/** A private function to retrieve a structure type from the type table and 
 * does an appropriate error handling for each error case. */
typetab_entry *get_structure(char *structure) {
    typetab_entry *struct_entry = h_get(typetab, struct_name);
    if (!struct_entry) {
        debug("get_structure::ERROR: invalid structure name %s", struct_name);
        return NULL;
    }
    if (struct_entry->kind != STRUCT_T) {
        debug("get_structure::ERROR: %s is not a structure", struct_name);
        return NULL;
    }
    return struct_entry;
}

typetab_entry *insert_typedef(char *type_name, type_enum _t) {
    typetab_entry *t = malloc(sizeof(typetab_entry));
    strcpy(t->name, type_name);
    t->type = _t;
    t->kind = TYPEDEF_T;
    t->next = NULL;
    if (!h_insert(typetab, type_name, t)) {
        /* error handling: key collision*/
        debug("insert_typedef::ERROR: collision occurred while inserting %s", 
                type_name);
        return NULL;
    }
    debug("insert_type:: %s(%d) of typedef inserted succesfully\n", 
            type_name, _t);
    return t;
}

typetab_entry *insert_struct(char *struct_name) {
    typetab_entry *t = malloc(sizeof(typetab_entry));
    strcpy(t->name, struct_name);
    t->type = STRUCT_TY;
    t->kind = STRUCT_T;
    t->next = NULL;
    if (!h_insert(typetab, struct_name, t)) {
        /* error handling: key collision*/
        debug("insert_typedef::ERROR: collision occurred while inserting %s", 
                type_name);
        return NULL;
    }
    return t;
}

typetab_entry *insert_field(char *struct_name, char *field_name, 
        type_enum field_type) {
    typetab_entry *struct_entry = get_structure(struct_name);
    if (!struct_entry) {
        return NULL;
    }
    // create a field
    typetab_entry *field = malloc(sizeof(typetab_entry));
    strcpy(field->name, field_name);
    field->kind = FIELD_T;
    field->type = field_type;
    field->next = NULL;
    
    // attach the field to the belonging structure
    typetab_entry *handle = struct_entry;
    while (handle->next) {
        /* move the handle to the last element of the linked list 
         * while checking for name collision */
        if (strcmp(handle->name, field_name) == 0) {
            // duplicate member name
            debug("indert_field::ERROR: field name %s already exists"
                    "in structure %s", field_name, struct_name);
        }
    }
    handle->next = t;   // attach
    // do not insert the field itself to the type table.
    return t;
}


bool is_type_exists(char *type) {
    return h_get(typetab, type) ? true : false;
}


//TODO: refactor
type_enum get_type(char *type) {
  typetab_entry *t = (typetab_entry *)h_get(typetab,type);
  if (t!=NULL) {
    debug("get_type %s has type (%d)\n",type,t->type);
    return t->type;
  } else {
    debug("get_type %s returning default type\n", type);
    return INT_TY;
  }
}

type_enum get_field_type(char *structure, char *field) {
    typetab_entry *handle = get_structure(structure);
    if (!handle) {
        return ERROR_TY;
    }
    while (handle->next) {
        if (handle->kind == FILED_T && strcmp(handle->name, field) == 0) {
            return handle->type;
        }
    }
    return ERROR_TY;
}
  
void init_typetab() {
    typetab = h_init();
}

// TODO: remove & replace the call to this with insert_field
struct_field *create_field(char *name, type_enum type) {
  struct_field *sf = malloc(sizeof(struct_field));
  strcpy(sf->f_name,name);
  sf->f_type=type;
  sf->next=NULL;
  debug("create_field field %s(%d) created",name,type);
  return sf;
}

// TODO: remove
typetab_entry *get_type_obj(char *type ){
  debug("get_type_obj getting type object for type %s",type);
  typetab_entry *t = (typetab_entry *)h_get(typetab,type);
  struct_field *sf = t->next;
  while(sf != NULL) {
    debug("get_type_obj found field %s(%d) in type %s",sf->f_name, sf->f_type,type);
    sf = sf->next;
  }
  return t;
}

