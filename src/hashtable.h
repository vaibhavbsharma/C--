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

/** @brief Initialize the hash table
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

/** Retrieve an entry from the hash table
 *
 * @param  key key to search for
 * @return the data object of an entry with <tt>key</tt> if found, 
 *         or <tt>NULL</tt> otherwise.
 * */
void *h_get(char *key);

#endif
