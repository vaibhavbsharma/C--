#include <stdio.h>

int global;

int main() {
  int i=0, j=0, k=0;
  global=i;
  global=j;
  return global;
}
