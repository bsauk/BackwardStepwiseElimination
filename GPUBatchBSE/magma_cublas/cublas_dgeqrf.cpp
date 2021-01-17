#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <cuda_runtime.h>
#include <cublas_v2.h>
#include <cuda.h>

int main(int argc, char *argv[]) {

  int M, N;
  cublasHandle_t cublasH;
  double *h_A, *h_R, *d_A, *dtau_cublas;
  int *dinfo_cublas;

  cublasCreate(&cublasH);

  cublasDgeqrfBatched(cublasH, M, N, d_Aarray, ldda, d_tauarray, info, N);


}
