#include <stdio.h>
#include <lapacke.h>
#include <sys/time.h>
extern "C" {
#include "subset.h"
}

extern "C" float goldSubset(int m, int n, int r, unsigned long batchSize) {
  int lda = ((m+15)/16)*16;
  double **A, **b;
  int info, nrhs, i;
  struct timeval tv1, tv2;
  float elapsed = 0;
  nrhs = 1;
  int count=0;
  int bigNum = 1.25e9 / (lda*(r+1)*sizeof(double));
  while(batchSize > bigNum) {
    batchSize = (batchSize+1)/2;
    count=count+1;
  }

  A = (double **)malloc(batchSize*sizeof(double*));
  b = (double **)malloc(batchSize*sizeof(double*));

  for(i=0; i<batchSize; i++) {
    A[i] = (double *)malloc(lda*r*sizeof(double));
    b[i] = (double *)malloc(lda*sizeof(double));
  }

  for(int block=0; block<count; block++) {
    matrixInit(block, A, b, batchSize, lda*r, lda);
    float iterTime = 0;
    gettimeofday(&tv1, NULL);
    for(i=0; i<batchSize; i++) {
      info = LAPACKE_dgels(LAPACK_COL_MAJOR,'N',m,r,nrhs,A[i],lda,b[i],lda);
    }
    gettimeofday(&tv2, NULL);
    iterTime = (float) (tv2.tv_usec - tv1.tv_usec)/1000000 + (float) (tv2.tv_sec - tv1.tv_sec);
    if(info != 0) printf("error\n");
    elapsed = elapsed + iterTime;
  }
  free(A);
  free(b);
  
  return elapsed;
  
}

extern "C" float testGold(int m, int n, int r, int batchSize) {
  int lda = ((m+15)/16)*16;
  double **A, **b;
  int info, nrhs, i;
  struct timeval tv1, tv2;
  float elapsed = 0;
  nrhs = 1;
  A = (double **)malloc(batchSize*sizeof(double*));
  b = (double **)malloc(batchSize*sizeof(double*));

  for(i=0; i<batchSize; i++) {
    A[i] = (double *)malloc(lda*r*sizeof(double));
    b[i] = (double *)malloc(lda*sizeof(double));
  }

  matrixInit(0, A, b, batchSize, lda*r, lda);
 
  float iterTime = 0;
  gettimeofday(&tv1, NULL);
   
  for(i=0; i<batchSize; i++) {
    info = LAPACKE_dgels(LAPACK_COL_MAJOR,'N',m,r,nrhs,A[i],lda,b[i],lda);
  }
  gettimeofday(&tv2, NULL);
  iterTime = (float) (tv2.tv_usec - tv1.tv_usec)/1000000 + (float) (tv2.tv_sec - tv1.tv_sec);
  if(info != 0) printf("error\n");
  elapsed = elapsed + iterTime;

  free(A);
  free(b);
  
  return elapsed;
  
}
