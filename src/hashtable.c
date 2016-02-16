/**@file hashtable.c
 *
 * A simple hash table implementation
 *
 * @author Taejoon Byun
 */

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
    for (int i=0; i<strlen(text); i++) {
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
    ht_size ++;
    return true;
}

/** Insert a node
 * @param key the key
 * @param data pointer to a data object (of any type)
 * @return true if insertion succeed, false if fail
 */
bool h_insert_entry(entry_t *ent) {
#if DEBUG
    printf("h_insert_entry('%s')\n", ent->key);
#endif
    if (h_table[ent->index]->index == -1) {
        // empty
        free(h_table[ent->index]);
        h_table[ent->index] = ent;
        ht_size ++;
        return true;
    } else {
        return ll_insert(h_table[ent->index], ent);
    }
}

void h_init() {
#if DEBUG
    printf("h_init()\n");
#endif
    h_table = malloc(sizeof(entry_t) * HT_SIZ);
    for (int i=0; i<HT_SIZ; i++) {
        h_table[i] = malloc(sizeof(entry_t));
        h_table[i]->index = -1;
    }
    ht_size = 0;
}

bool h_insert(char *key, void *data) {
#if DEBUG
    printf("h_insert('%s')\n", key);
#endif
    entry_t *entry = (entry_t*) malloc(sizeof(entry_t));
    entry->index = hash(key);
    entry->key = (char*) malloc(strlen(key) * sizeof(char));
    strcpy(entry->key, key);
    entry->data = data;
    entry->next = NULL;
    return h_insert_entry(entry);
}

void *h_get(char *key) {
    if (h_table[hash(key)]->index == -1) {
        return NULL;
    } else {
        entry_t *found = ll_search(h_table[hash(key)], key);
        if (found != NULL) {
            return found->data;
        } else {
            return NULL;
        }
    }
}

void **ht_to_list(int *size) {
    int ind = 0;
    void **list = malloc(ht_size * sizeof(void*));
    for (int i=0; i<HT_SIZ; i++) {
        if (h_table[i]->index == -1) {
            continue;
        }
        entry_t *handle = NULL;
        do {
            handle = h_table[i];
            list[ind++] = handle->data;
            handle = handle -> next;
        } while(handle);
    }
    *size = ind;
#if DEBUG 
    for (int i=0; i<ind; i++) {
        printf("id: %s\n", (char *) list[i]);
    }
#endif
    return list;
}

