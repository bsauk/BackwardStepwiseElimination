// includes, system
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include <cuda.h>  // for CUDA_VERSION
#include <cuda_runtime.h>
// includes, project
#include "magma_v2.h"
#include "magma_lapack.h"

#ifndef DEBUG
#define DEBUG 0
#endif

int main(int argc, char *argv[]) {

#define d_A(i,j) (d_A + (i) + (j)*ldda)

  magma_init();
  real_Double_t t1, dgels_time, cublas_time;

  double *h_A, *h_R;
  double *d_A, *dtau_magma, *dtau_cublas;

  double **dA_array = NULL;
  double **dtau_array = NULL;
  
  magma_int_t   *dinfo_magma, *dinfo_cublas;
    
  magma_int_t M, N, lda, ldda, n2, n3;
  magma_int_t ione     = 1;
  magma_int_t ISEED[4] = {0,0,0,1};
  //  int status = 0;
  
  magma_int_t column;
  magma_queue_t queue;
  int info;
  cublasHandle_t cublasH;
  cudaEvent_t dgeqrf_end;
  cublasCreate(&cublasH);
  cudaEventCreate(&dgeqrf_end);

  dgels_time = 0;
  magma_queue_create(0,&queue);

  M = atoi(argv[1]);
  N = atoi(argv[2]);

  lda    = M;
  n2     = lda*N * N;
  n3     = lda*N;
  ldda = M;
  ldda   = magma_roundup( M, 32 );  // multiple of 32 by default
  
  /* Allocate memory for the matrix */
  magma_dmalloc_cpu( &h_A,   n2     );
  magma_dmalloc_pinned( &h_R,   n2     );

  magma_dmalloc( &d_A,   ldda*N * N );
  magma_dmalloc( &dtau_magma,  N * N );
  magma_dmalloc( &dtau_cublas,  N * N );
  
  magma_imalloc( &dinfo_magma,  N );
  magma_imalloc( &dinfo_cublas,  N );
  
  
  magma_malloc( (void**) &dA_array,   N * sizeof(double*) );
  magma_malloc( (void**) &dtau_array, N * sizeof(double*) );
 
  column = N * N;

  /* Initialize the matrix */
  lapackf77_dlarnv( &ione, ISEED, &n3, h_A );
  lapackf77_dlacpy( MagmaFullStr, &M, &column, h_A, &lda, h_R, &lda );

  magma_dsetmatrix( M, column, h_R, lda,  d_A, ldda, queue );
  magma_dset_pointer( dA_array, d_A, 1, 0, 0, ldda*N, N, queue );
  magma_dset_pointer( dtau_array, dtau_magma, 1, 0, 0, N, N, queue );

  t1 = magma_sync_wtime(queue);
  info = magma_dgeqrf_batched(M, N, dA_array, ldda, dtau_array, dinfo_magma, N, queue); // full problem qr and update!
  if(DEBUG && info != 0) {
    printf("Error in dgeqrf2_batched!\n");
  }
  dgels_time = magma_sync_wtime(queue) - t1 + dgels_time;
    
  printf("MAGMA dgeqrf Time=%f ms\n", 1000*dgels_time); 

  /*=================================================================
    CUBLAS Operation
    =================================================================*/

  magma_dsetmatrix( M, column, h_R, lda,  d_A, ldda, queue );
  magma_dset_pointer( dA_array, d_A, 1, 0, 0, ldda*N, N, queue );
  magma_dset_pointer( dtau_array, dtau_cublas, 1, 0, 0, N, N, queue );

  cublas_time = magma_sync_wtime(queue);
  int cublas_info;
  cublasDgeqrfBatched( cublasH, int(M), int(N), dA_array, int(ldda), dtau_array, &cublas_info, int(N) );
  cudaEventRecord(dgeqrf_end);
  cudaEventSynchronize(dgeqrf_end);

  cublas_time = magma_sync_wtime( queue ) - cublas_time;
  if(cublas_info != 0) {
    printf("cublasDgeqrfBatched returned error %lld: %s.\n",
	   (long long) cublas_info, magma_strerror( cublas_info ));
  }  
  printf("CUBLAS dgeqrf Time=%f ms\n", 1000*cublas_time); 

  return 0;

}
