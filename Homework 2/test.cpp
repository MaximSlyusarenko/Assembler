#include "matrix.h"
#include <stdio.h>

void print_matrix(FILE * fp, Matrix m)
{
    fprintf(fp, "%p ", m);
    if (!m)
    {
        return;
    }
    int n = matrixGetRows(m);
    int m1 = matrixGetCols(m);
    fprintf(fp, "%d %d\n", n, m1);
    for(int i = 0; i < n; i++)
    {
        for(int j = 0; j < m1; j++)
        {
            fprintf(fp, "%6.2f ", matrixGet(m, i, j));
        }
        fprintf(fp, "\n");
    }
    fprintf(fp, "\n");

}

int main()
{
    Matrix m1 = matrixNew(3, 2);
    Matrix m2 = matrixNew(2, 3);

    matrixSet(m1, 0, 0, 3.f);
    matrixSet(m1, 1, 1, 2.f);
    matrixSet(m1, 2, 1, 1.f);
    matrixSet(m1, 1, 0, 4.f);
    matrixSet(m1, 2, 0, 24.f);

    matrixSet(m2, 0, 0, 3.f);
    matrixSet(m2, 1, 1, 2.f);
    matrixSet(m2, 0, 2, 5.f);
    matrixSet(m2, 1, 2, 4.f);
    matrixSet(m2, 1, 0, 12.f);
    print_matrix(stdout, m1);
    print_matrix(stdout, m2);

    Matrix m3 = matrixMul(m1, m2);
    print_matrix(stdout, m3);

    Matrix m4 = matrixNew(3, 2);
    matrixSet(m4, 0, 0, 1);
    matrixSet(m4, 0, 1, 100);
    matrixSet(m4, 1, 0, 200);
    matrixSet(m4, 1, 1, 12);
    matrixSet(m4, 2, 0, 75);
    matrixSet(m4, 2, 1, 23);
    print_matrix(stdout, m4);
    Matrix m5 = matrixAdd(m1, m4);
    print_matrix(stdout, m5);

    Matrix m6 = matrixScale(m5, 2.0f);
    print_matrix(stdout, m6);

    matrixDelete(m1);
    matrixDelete(m2);
    matrixDelete(m3);
    matrixDelete(m4);
    matrixDelete(m5);
    matrixDelete(m6);
}