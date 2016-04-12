#include "codegen.h"
#define DEBUG

int main() {
    intstack_t *s = s_init();
    printf("push: 1\n");
    s_push(s, 1);
    printf("push: 2\n");
    s_push(s, 2);
    printf("get: %d\n", s_get(s));

    printf("pop\n");
    s_pop(s);
    printf("get after pop: %d\n", s_get(s));

    printf("pop\n");
    s_pop(s);
    printf("get after pop: %d\n", s_get(s));

    printf("pop\n");
    s_pop(s);
    printf("get after pop: %d\n", s_get(s));
    return 0;
}
