#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "calc_matrix.h"

#define MAX_MATRIX_VALUE 254    //maxvalue specified by task assigned at Uni
#define MAX_DIM_VALUE 10        //maximum dimenstion specified by task (..)


bool checkOperator(char c)
{
    if (c == '+' || c == '-' || c == '*' || c == 'd')
        return true;
    return false;
}

void checkDims(char operand, int *dims) 
{
    bool err = false;
    if ( operand == '+' || operand == '-' ) {               //add-sub check
        if ( dims[0] != dims[2] || dims[1] != dims[3] )
            err = true;
    }    
    else if ( operand == '*' ) {                            //mul check
        if ( dims[0] != dims[3] )
            err = true;
    } 
    else {                                                  //det check
        if ( dims[0] != dims[1] )                           // n x n only
            err = true;

        if ( dims[0] > 3 || dims[1] > 3 )                   //only up to 3x3 implemented
            err = true;
    }

    if (operand != 'd')
    {
        if (dims[0] > MAX_DIM_VALUE || dims[1] > MAX_DIM_VALUE || dims[2] > MAX_DIM_VALUE || dims[3] > MAX_DIM_VALUE)
            err = true;
        
        if (dims[0] < 1 || dims[1] < 1 || dims[2] < 1 || dims[3] < 1)
            err = true;

    } else {    //det only should check dims for M1

        if (dims[0] > MAX_DIM_VALUE || dims[1] > MAX_DIM_VALUE)
            err = true;
        if (dims[0] < 1 || dims[1] < 1)
            err = true;
    }

    if ( err ) {
        perror("Wrong dims for this operation!");
        exit(1);
    }
}

int getResNewLines(char operand, int *dims) 
{
    if ( operand == '+' || operand == '-' || operand == '*')
        return dims[0]; //return matrix number of columns
    else
        return 0;
}

void checkValueBoundaries(int *matrix, int size) 
{
    for (int i = 0; i < size; i++)
    {
        if ( matrix[i] > MAX_MATRIX_VALUE || matrix[i] < -MAX_MATRIX_VALUE)
        {
            perror("Matrix value out of boundaries");
            exit(1);
        }
    }
}
void printHelp()
{
    printf( "1. Read from input file\n"
            "2. Calculate matrices in x86_64 methods\n"
            "3. Print result of calculated matrix\n"
            "4. Save to output file\n"
            "5. Print this message\n"
            "6. Exit\n");
}

int main (int argc, char* argv[]){

    char operand;               // operand
    int resNewLines;            // number of new lines in output matrix
    int i;                      // counter for for-loops
    int* dims = NULL;           // dimensions array
    int* M1 = NULL;             // 1st matrix array
    int* M2 = NULL;             // 2nd matrix array
    int* res = NULL;            // output matrix array
    FILE* FI;                   // input file
    FILE* FO;                   // output file
    int* type;                  // argument of value 0 or 1 for add_sub_matrices
    int temp;                   // stores temporary values
    int pick;                   // stores user choice of action
    int sizeOfRes;              // holds sizeof output matrix array, as sizeof(int *) is unreliable in C
    bool resetNeeded = false;   // boolean for reseting memory on each file read
    
    printHelp();

    while (true) {
        
        printf("Your choice: ");
        scanf("%d", &pick);

        switch(pick) {
            case 1: //read input 
            {   
                /* if file was read previously, free memory */
                if ( resetNeeded )
                {
                    free(dims);
                    free(M1);
                    free(M2);
                    free(res);
                    dims = NULL;
                    M1 = NULL;
                    M2 = NULL;
                    res = NULL;
                    resetNeeded = false;
                }
                /* Open input file */
                if ( !(FI = fopen("input.txt", "r")) )
                {
                    perror("I/O error");
                    exit (1);
                }
                /* Get operator */
                fscanf(FI, "%c", &operand);

                /* Check if operator is correct */
                if ( !checkOperator(operand) )
                {
                    perror("Wrong operand");
                    exit(1);
                }

                /* Allocate memory for dimension values */
                if (dims == NULL) {
                    dims = malloc(sizeof(int)*4);
                }
                /* Scan for column and row count of matrix1 */
                fscanf(FI, "%d %d", &dims[0], &dims[1]);

                /* Allocate memory for matrix1 */
                if (M1 == NULL)
                    //M1 = realloc(M1, sizeof(int)*dims[0]*dims[1]);
                    M1 = malloc(sizeof(int)*dims[0]*dims[1]);

                /* Fill matrix1 with data */
                for(i = 0; i < dims[0]*dims[1]; i++) 
                {
                    fscanf(FI, "%d", &M1[i]);
                }

                checkValueBoundaries(M1, dims[0]*dims[1]);

                /* Scan for column and row count of matrix2 if we're not calculating det */
                if ( operand != 'd' )
                {
                    fscanf(FI, "%d %d", &dims[2], &dims[3]);

                    /* Allocate memory for matrix2 */
                    if(M2 == NULL)
                        M2 = malloc(sizeof(int) * dims[2] * dims[3]);

                    /* Fill matrix2 with data */
                    for(i = 0; i < dims[2]*dims[3]; i++)
                    {
                        fscanf(FI, "%d", &M2[i]);
                    }

                    checkValueBoundaries(M2, dims[2]*dims[3]);
                }
            
                /* Close input file */
                fclose(FI);

                /* Check if dimensions are correct for given operation */
                checkDims(operand, dims);

                /* Alloc correct size of result matrix */
                if ( operand == '+' || operand == '-' ) 
                {
                        type = malloc(sizeof(int));
                        res = malloc(sizeof(int)*dims[0]*dims[1]); //both matrices same size, output of size x*y of either
                        sizeOfRes = dims[0]*dims[1];
                }
                else if ( operand == '*' ) 
                {
                        res = malloc(sizeof(int)*dims[0]*dims[3]);  //output of size y1 * x2
                        sizeOfRes = dims[0]*dims[3];
                }
                else 
                {
                        res = malloc(sizeof(int) + 1);
                        sizeOfRes = 1;
                }
                /* boolean for next file read */
                resetNeeded = true;


                printf("File successfully read. Memory allocated.\n");
                break;         
            }
            case 2: //launch x86
            {
                /* Call x86 method */
                switch(operand) {
                    case '+':
                        temp = 0;
                        type = &temp;
                        add_sub_matrices(dims, M1, M2, res, type);
                        break;
                    case '-':
                        temp = 1;
                        type = &temp;
                        add_sub_matrices(dims, M1, M2, res, type);
                        break;
                    case '*':
                        mul_matrices(dims, M1, M2, res);
                        break;
                    case 'd':
                        det_matrix(dims, M1, res);
                        break;
                    default:
                        break;
                }

                /* Check if result values are in boundaries */
                if (operand != 'd')
                    checkValueBoundaries(res, sizeOfRes);

                
                printf("Matrix calculated using x86.\n");
                break;
            }
            case 3: //print x86 effect
            {
                printf("Result matrix: \n");
                for (int i = 0; i < sizeOfRes; i++)
                {
                    printf("%d ", res[i]);
                    if ( ((i+1) % dims[0] == 0) && i > 0 ) //print new line after each row
                        printf("\n");
                }
                printf("\n");
                break;
            }
            case 4: //save to output file
            {
                /* Open output file */
                if ( !(FO = fopen("output.txt", "w")) )
                {
                    perror("I/O error");
                    exit(1);
                }

                resNewLines = getResNewLines(operand, dims);

                /* if res is a matrix and not a single value*/
                if ( operand != 'd' )
                {
                    int charsBeforeNewLine = dims[3];
                    for(i = 0; i < sizeOfRes; i++)
                    {
                        fprintf(FO, "%d ", res[i]);
                        charsBeforeNewLine--;
                        if(charsBeforeNewLine == 0)
                        {
                            fprintf(FO, "\n");
                            charsBeforeNewLine = dims[3];
                        }
                    }

                /* fprintf only one value - determinant */
                } else {
                    fprintf(FO, "%d", res[0]);
                }

                /* Close output file */
                fclose(FO);

                printf("Data saved to file.\n");
                break;
            }
            case 5: //print help message
                printHelp();
                break;
            case 6: //exit
                exit(0);
                break;
            default:
                printf("No such command!\n");
                break;
        }
    }

    printf("Success!");
    return 0;
}