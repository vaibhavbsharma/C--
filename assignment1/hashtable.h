/** @file hashtable.h
 *
 * A simple hash table implementation
 *
 * @author Taejoon Byun
 */

#ifndef HASHTABLE_H
#define HASHTABLE_H


#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>
#include <stdio.h>

/** Hash table size */
#define HT_SIZ 100

/** hash table entry */
typedef struct entry_t {
    unsigned int index; /**< index */
    char *key;          /**< key value */
    void *data;         /**< the pointer to the data (of any type) */
    struct entry_t *next;      /**< a pointer to the next entry */
} entry_t;

/** a hash table */
entry_t **h_table;

int ht_size;

/** Initialize the hash table
*/
void h_init();

/** Insert a <i> key - data </i> pair to the hash table
 *
 * @param key the key string
 * @param data a pointer to the data object of any kind
 * @return true if succeed, false if key collision occurs
 *
 * @see h_insert_entry ll_insert
 * */
bool h_insert(char *key, void *data);

/** Retrieve a data object that corresponds to a given key from the hash table
 *
 * @param  key key to search for
 * @return the data object of an entry with <tt>key</tt> if found, 
 *         or <tt>NULL</tt> otherwise.
 * */
void *h_get(char *key);

/** Retrieve all the entries in the hash table as a list
 *
 * @param   size a point to an integer where the size of the returning list
 *          is to be stored
 * @return  list of pointers to data object
 */
void **ht_to_list(int *size);

/** Remove an entry from the table
 * @param key  the key to remove 
 * @return true if successful, false if no element with <tt>key</tt> exists
 * */
bool h_remove(char *key);


/* ----- other internal (private) functions ----- */

int hash(char *text);

entry_t *ll_search(entry_t *first, char *key);

bool ll_insert(entry_t *first, entry_t *node);

bool h_insert_entry(entry_t *ent);

entry_t *h_get_entry(char *key);


#endif
