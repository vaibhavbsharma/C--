/**@file hashtable.c
 *
 * A simple hash table implementation
 *
 * @author Taejoon Byun
 */
#include "common.h"
#include "hashtable.h"

/**
 * @brief A simple hash function that hashes a string to an integer value
 *
 * This function hashes a string to an unsigned integer value between 0 and <tt>HT_SIZ</tt>.
 *
 * @param str a string to hash
 * @return an unsigned integer between 0 and <tt>HT_SIZ</tt>
 * @see HT_SIZ
 * */
int hash(char *text) {
    unsigned int sum = 0;
    int i;
    for (i=0; i<strlen(text); i++) {
        sum += text[i];
    }
    return sum % HT_SIZ;
}

/** Search through a linked list 
 * @param first the first node of a linked list
 * @param the key to look for
 * @return matching node, or NULL if not found
 * */
entry_t *ll_search(entry_t *first, char *key) {
    assert(first != NULL && key != NULL);
    if (first == NULL || key == NULL) {
        return NULL;
    }
    entry_t *handle = first;
    do {
        if (strcmp(handle->key, key) == 0) {
            return handle;
        }
        handle = handle->next;
    } while (handle);
    // not found
    return NULL;
}

/** Insert to a linked list
 * @param first the frist node of a linked list
 * @param node a node to insert
 * @return false if insertion failed (key collision)
 * */
bool ll_insert(entry_t *first, entry_t *node) {
    assert(first != NULL && node != NULL);
    if (ll_search(first, node->key) != NULL) {
        // duplicate found
        return false;
    }
    entry_t *handle = first;
    while (handle->next) {
        handle = handle->next;
    }
    handle->next = node;
    return true;
}

/** Insert a node
 * @param key the key
 * @param data pointer to a data object (of any type)
 * @return true if insertion succeed, false if fail
 */
bool h_insert_entry(entry_t **h_table, entry_t *ent) {
    if (h_table[ent->index]->index == -1) {
        // empty
        free(h_table[ent->index]);
        h_table[ent->index] = ent;
        return true;
    } else {
        return ll_insert(h_table[ent->index], ent);
    }
}

/** Loop-up an entry from the hash table
 * @param key   the key to search for
 * @return the pointer of an entry, or NULL if not found
 */
entry_t *h_get_entry(entry_t **h_table, char *key) {
    if (h_table[hash(key)]->index == -1) {
        return NULL;
    } else {
        entry_t *found = ll_search(h_table[hash(key)], key);
        if (found != NULL) {
            return found;
        } else {
            return NULL;
        }
    }
}

entry_t **h_init() {
    entry_t **h_table = malloc(sizeof(entry_t) * HT_SIZ);
    int i;
    for (i=0; i<HT_SIZ; i++) {
        h_table[i] = malloc(sizeof(entry_t));
        h_table[i]->index = -1;
        h_table[i]->next = NULL;
    }
    ht_size = 0;
    return h_table;
}

bool h_insert(entry_t **h_table, char *key, void *data) {
    entry_t *entry = (entry_t*) malloc(sizeof(entry_t));
    entry->index = hash(key);
    entry->key = (char*) malloc(strlen(key)+1 * sizeof(char));
    strcpy(entry->key, key);
    entry->data = data;
    entry->next = NULL;
    return h_insert_entry(h_table, entry);
}

void *h_get(entry_t **h_table, char *key) {
    entry_t *found = h_get_entry(h_table, key);
    if (found != NULL) {
        return found->data;
    } else {
        return NULL;
    }
}

void **ht_to_list(entry_t **h_table, int *size) {
    int ind = 0, cnt = 0;
    if (!h_table) {
        fprintf(stderr, "wrong pointer to a hash table\n");
        return NULL;
    }
    for (int i=0; i<HT_SIZ; i++) {
        if (h_table[i]->index == -1) {
            continue;
        }
        entry_t *handle = h_table[i];
        do {
            if (handle) cnt++;
        } while ((handle = handle->next));
    }
    void **list = malloc(cnt * sizeof(void*));
    /* traverse through the table and copy only 
     * the pointers to data object to the list */
    for (int i=0; i<HT_SIZ; i++) {
        if (h_table[i]->index == -1) {
            continue;
        }
        entry_t *handle = NULL;
        handle = h_table[i];
        do {
            if (handle) {
                list[ind++] = handle->data;
            }
            handle = handle->next;
        } while (handle);
    }
    *size = ind;
    for (int i=0; i<ind; i++) {
        debug("hashtable.c::ht_to_list() id: %s", (char *) list[i]);
    }
    return list;
}

bool h_remove(entry_t **h_table, char *key) {
    entry_t *found = h_get_entry(h_table, key);
    if (found == NULL) {
        return false;
    }
    /* traverse the linked list of the index `hash(key)` from the head */
    entry_t *prev = NULL;
    entry_t *curr = h_table[hash(key)];
    while (curr != found) {
        prev = curr;
        curr = curr->next;
    }
    if (prev != NULL) {
        /* there is a previous node to link to the next node
         * : link `prev` to `next` */
        prev->next = curr->next;
        //free(curr->key);
        free(curr->data);
        //free(curr);
    } else {
        /* there is not; the node to delete is the first one 
         * in the linked list */
        // free & initialize
        //free(curr->key);
        free(curr->data);
        curr->index = -1;
        curr->next = NULL;
    }
    debug("hashtable.c::h_remove(%s)", key);
    return true;
}

