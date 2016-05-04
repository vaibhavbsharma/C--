#include <stdio.h>

int global;

int main() {
  int i=0, j=0, k=0;
  global=i; //Store removed by StoresRemoval compiler pass
  global=j; //Store removed by StoresRemoval compiler pass
  global=i;
  if(i>0) printf("greater\n");
  return global;
}
