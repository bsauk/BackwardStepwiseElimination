#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <cublas_v2.h>
extern "C" {
#include "subset.h"
}

int fact(int z) {
  
  int f = 1;
  if(z == 0) {
    return f;
  } else {
    for(int i=1; i <= z; i++) {
      f = f*i;
    }
  } 
  return (f);
}

unsigned long comb(int n, int r) {
  unsigned long f = 1;
  if(n==r) {
    return f;
  } else {
    for(int i=n; i>n-r; i--) {
      f = f*i;
    }
  }

  f = f/fact(r);

  return f;
}  

void matPrint(double *A, int m, int count) {
  char p[4]= {'A', 'B', 'x', '\0'};
  for(int i=0; i<m; i++) {
    printf("%c(%d)=%f;\n", p[count], i+1, A[i]);
  }
}

void matrixInit(int in, double **A, double **B, int batchSize, int lim1, int lim2) {
    
  // Code to either make matrix or initialize it
  int i=0; 
  int j=0; 
  double div = RAND_MAX/1000;
  srand((unsigned) in);
  for(j=0; j<batchSize; j++) {
    for(i=0; i<lim1; i++) { 
      A[j][i] = rand()/div;
    }
  }
  for(j=0; j<batchSize; j++) {
    for(i=0; i<lim2; i++) {
      B[j][i] = rand()/div;
    }
  }
}

//float testMagma(int m, int n, int r, int batchSize) {


//}


float testSubset(int m, int n, int r, int batchSize) {
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  cublasHandle_t cublas_handle;

  cublasCreate(&cublas_handle);

  int info, i, nrhs, lda;
  float gpuTime = 0, iterTime = 0; 
  
  info = 0;
  nrhs = 1;
  lda = ((m+15)/16)*16;
  int *devInfoArray;
  double **A, **B;
  double **dA, **dB, **hdA, **hdB;

  cudaMalloc((void**)&devInfoArray, batchSize*sizeof(int));
  A = (double **)malloc(batchSize*sizeof(double*));
  B = (double **)malloc(batchSize*sizeof(double*));
  for(i=0; i<batchSize; i++) {
    A[i] = (double *)malloc(lda*r*sizeof(double));
    B[i] = (double *)malloc(lda*sizeof(double));
  }

  hdA = (double **)malloc(batchSize*sizeof(double*));
  hdB = (double **)malloc(batchSize*sizeof(double*));

  for(i=0; i<batchSize; i++) {
    cudaMalloc((void**)&hdA[i], lda*r*sizeof(double));
    cudaMalloc((void**)&hdB[i], lda*sizeof(double));
  }
  
  cudaMalloc((void**)&dA, batchSize*sizeof(double*));
  cudaMalloc((void**)&dB, batchSize*sizeof(double*));

  matrixInit(0, A, B, batchSize, lda*r, lda);

  cudaEventRecord(start);
  // Code to calculate SSE from subset
  for(i=0; i<batchSize; i++) {
    cublasSetMatrix(m, r, sizeof(double), A[i], lda, hdA[i], lda);
    cublasSetMatrix(m, 1, sizeof(double), B[i], lda, hdB[i], lda);
  }
  cudaMemcpy(dA, hdA, batchSize*sizeof(double*), cudaMemcpyHostToDevice);
  cudaMemcpy(dB, hdB, batchSize*sizeof(double*), cudaMemcpyHostToDevice);

  cublasDgelsBatched(cublas_handle, CUBLAS_OP_N, m, r, nrhs, dA, lda, dB, lda, &info, devInfoArray, batchSize);
    
  cudaDeviceSynchronize();

  for(i=0; i<batchSize; i++) {
    cublasGetMatrix(m, 1, sizeof(double), hdB[i], lda, B[i], lda);
  } 

  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  iterTime = 0;
  cudaEventElapsedTime(&iterTime, start, stop);

  gpuTime = gpuTime + iterTime;

  for(int i=0; i<batchSize; i++) {
    free(A[i]);
    free(B[i]);
    cudaFree(hdA[i]);
    cudaFree(hdB[i]);
  }
  if(dA) cudaFree(dA);
  if(dB) cudaFree(dB);
  cudaEventDestroy(start);
  cudaEventDestroy(stop);
  cublasDestroy(cublas_handle);
  if(A) free(A);
  if(B) free(B);
  if(hdA) free(hdA);
  if(hdB) free(hdB);

  return gpuTime;
}


float allSubset(int *bestSubset, double *bestSSE, int m, int n, int r, unsigned long batchSize) {
  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
  cublasHandle_t cublas_handle;

  cublasCreate(&cublas_handle);

  int info, i, count, nrhs, lda;
  float gpuTime = 0, iterTime = 0; 
  
  count = 1;
  info = 0;
  nrhs = 1;
  lda = ((m+15)/16)*16;
  int *devInfoArray;
  double **A, **B;
  double **dA, **dB, **hdA, **hdB;

  unsigned long bigNum = 1.25e9 / (lda*(r+1)*sizeof(double));
  while(batchSize > bigNum) {
    batchSize = (batchSize+1)/2; 
    count = count+1;
  }

  cudaMalloc((void**)&devInfoArray, batchSize*sizeof(int));
  A = (double **)malloc(batchSize*sizeof(double*));
  B = (double **)malloc(batchSize*sizeof(double*));
  for(i=0; i<batchSize; i++) {
    A[i] = (double *)malloc(lda*r*sizeof(double));
    B[i] = (double *)malloc(lda*sizeof(double));
  }

  hdA = (double **)malloc(batchSize*sizeof(double*));
  hdB = (double **)malloc(batchSize*sizeof(double*));

  for(i=0; i<batchSize; i++) {
    cudaMalloc((void**)&hdA[i], lda*r*sizeof(double));
    cudaMalloc((void**)&hdB[i], lda*sizeof(double));
  }
  
  cudaMalloc((void**)&dA, batchSize*sizeof(double*));
  cudaMalloc((void**)&dB, batchSize*sizeof(double*));

  /* CODE TO READ IN OR WRITE A MATRIX */
  for(int block=0; block<count; block++) {
    matrixInit(block, A, B, batchSize, lda*r, lda);
    cudaEventRecord(start);
    // Code to calculate SSE from subset
    for(i=0; i<batchSize; i++) {
      cublasSetMatrix(m, r, sizeof(double), A[i], lda, hdA[i], lda);
      cublasSetMatrix(m, 1, sizeof(double), B[i], lda, hdB[i], lda);
    }
    cudaMemcpy(dA, hdA, batchSize*sizeof(double*), cudaMemcpyHostToDevice);
    cudaMemcpy(dB, hdB, batchSize*sizeof(double*), cudaMemcpyHostToDevice);

    cublasDgelsBatched(cublas_handle, CUBLAS_OP_N, m, r, nrhs, dA, lda, dB, lda, &info, devInfoArray, batchSize);
    
    cudaDeviceSynchronize();

    for(i=0; i<batchSize; i++) {
      cublasGetMatrix(m, 1, sizeof(double), hdB[i], lda, B[i], lda);
    } 

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    iterTime = 0;
    cudaEventElapsedTime(&iterTime, start, stop);

    gpuTime = gpuTime + iterTime;
    double sse = 0; 
    for(i=0; i<batchSize; i++) {
      sse = 0;
      for(int j=r; j<m; j++) {
	sse = sse + B[i][j]*B[i][j];
      }
      if(sse < bestSSE[0]) {
	bestSSE[0] = sse;
	bestSubset[0] = r;
	bestSubset[1] = block*batchSize+i;
      }
    }
  }

  for(int i=0; i<batchSize; i++) {
    free(A[i]);
    free(B[i]);
    cudaFree(hdA[i]);
    cudaFree(hdB[i]);
  }
  if(dA) cudaFree(dA);
  if(dB) cudaFree(dB);
  cudaEventDestroy(start);
  cudaEventDestroy(stop);
  cublasDestroy(cublas_handle);
  if(A) free(A);
  if(B) free(B);
  if(hdA) free(hdA);
  if(hdB) free(hdB);

  return gpuTime;
}
  
int main(int argc, char **argv)
{

  // Make/read in a matrix/alamo file
  // Goal is to compare all subsets up to size ENUM using Givens Rotations

  // A simple example is ./batchSubset 10 10 2 0 

  int m = atoi(argv[1]);
  int n = atoi(argv[2]);
  int ENUM=atoi(argv[3]);
  int *bestSubset = (int *)malloc(2*sizeof(int));
  int *currentSubset = (int *)malloc(2*sizeof(int));
  double *bestSSE = (double *)malloc(sizeof(double));
  double currentSSE = 1e10;
  unsigned long ncr = 0;

  float batchTime = 0;
  float goldTime = 0;

  bestSSE[0] = currentSSE;
  bestSubset[0] = 0;
  bestSubset[1] = 0;
  // Generate subsets and calculate SSE, only store if optimal
  for(int r=100; r<=300; r+=50) {
    goldTime = testGold(m, 8, n, r);
    batchTime = testSubset(m, 8, n, r);
    printf("BatchSize=%d goldTPS=%f s gpuTPS=%f s\n", r, goldTime/r, batchTime/(1000*r));
  }
}