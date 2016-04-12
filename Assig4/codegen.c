/** codegen.c 
 * Functions related to code generation
 * */
#include "codegen.h"
#include <stdlib.h>

stringlabel slabel_arr[100];
int sconst_label_counter=0;
int sconst_label_gen=0;

char *push_string_label(char *str) {
  char *label = malloc(sizeof(char)*LABEL_SIZE);
  sprintf(label,"_slabel%d",sconst_label_gen);
  strcpy(slabel_arr[sconst_label_counter].str,str);
  strcpy(slabel_arr[sconst_label_counter].label,label);
  sconst_label_counter++;
  sconst_label_gen++;
  return label;
}

void gen_string_labels() {
  for (int i=0;i<sconst_label_counter; i++)
    emit("%s: .asciiz %s",slabel_arr[i].label, slabel_arr[i].str);
  sconst_label_counter=0;
}

/* Maintain a list of register slots marked as free/occupied */
int temp_reg[8]={0};

intstack_t *s_init() {
    intstack_t *s = (intstack_t*) malloc(sizeof(intstack_t));
    s->index = -1;
    return s;
}

bool s_push(intstack_t *s, int n) {
    if (s->index >= STACK_SIZ) {
        debug("stack is full");
        return false;
    }
    s->stack[++(s->index)] = n;
    return true;
}

int s_get(intstack_t *s) {
    if (s->index < 0) {
        debug("stack is empty");
        return -1;
    }
    return s->stack[s->index];
}

bool s_pop(intstack_t *s) {
    if (s->index < 0) {
        // stack is empty
        debug("stack is empty");
        return false;
    }
    (s->index)--;
    return true;
}

void gen_func_prolog(char name[]) {
  emit(".text");
  emit("main:");
  emit("\tsw $ra, 0($sp)");
  emit("\tsw $fp, -4($sp)");
  emit("\tadd $fp, $sp, -4");
  emit("\tadd $sp, $sp, -8");
  emit("\tlw $2, _framesize_main");
  emit("\tsub $sp, $sp, $2");
  emit("\tsw $8, 32($sp)");
  emit("\tsw $9, 28($sp)");
  emit("\tsw $10, 24($sp)");
  emit("\tsw $11, 20($sp)");
  emit("\tsw $12, 16($sp)");
  emit("\tsw $13, 12($sp)");
  emit("\tsw $14, 8($sp)");
  emit("\tsw $15, 4($sp)");
  emit("_begin_main:");
}

void gen_func_epilog(char name[]) {
  emit("_end_main:");
  emit("\tlw $8, 32($sp)");
  emit("\tlw $9, 28($sp)");
  emit("\tlw $10, 24($sp)");
  emit("\tlw $11, 20($sp)");
  emit("\tlw $12, 16($sp)");
  emit("\tlw $13, 12($sp)");
  emit("\tlw $14, 8($sp)");
  emit("\tlw $15, 4($sp)");
  emit("\tlw $ra, 4($fp)");
  emit("\tadd $sp, $fp, 4");
  emit("\tlw $fp, 0($fp)");
  emit("\tli $v0, 10");
  emit("\tsyscall");
  emit(".data");
  emit("\t_framesize_main: .word 36");
  gen_string_labels();
}

int get_free_temp_reg() {
  for(int i=0;i<8;i++) {
    if(temp_reg[i]==0) {
      temp_reg[i]=1;
      //debug("get_free_temp_reg: returning free reg $%d",i+8);
      return i+8;
    }
  }
  debug("get_free_temp_reg: no free registers");
  return -1;
}

void mark_temp_reg_free(char *str) {
  if(!is_temp_reg(str)) 
    debug("mark_temp_reg_free(): %s is not a temp register and cannot be marked as free",str);
  else {
    //debug("mark_temp_reg_free(): marking %s as free",str);
    int reg;
    if(str[1]>='8' && str[1]<='9') 
      reg=str[1]-'8';
    else {
      reg=(str[1]-'0')*10+(str[2]-'0')-8;
    }
    //debug("mark_temp_reg_free(): got internal reg %d",reg);
    temp_reg[reg]=0;
    //debug("mark_temp_reg_free(): marked internal reg %d as free",reg);
  }
}

bool is_temp_reg(char *str) {
  return str[0]=='$';
}

