#ifndef CALC_MATRIX_H
#define CALC_MATRIX_H


void add_sub_matrices(int* dims, int* m1, int* m2, int* res, int* doSub); //doSub=0 == add, doSub=1 == subtract
void mul_matrices(int* dims, int* m1, int* m2, int* res);
void det_matrix(int* dims, int* m1, int* res);


#endif