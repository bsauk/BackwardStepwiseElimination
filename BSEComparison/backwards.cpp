// includes, system
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include <cuda.h>  // for CUDA_VERSION

// includes, project
#include "magma_v2.h"
#include "magma_lapack.h"

#ifndef DEBUG
#define DEBUG 0
#endif

#define d_A(i,j) (d_A + (i) + (j)*ldda)
#define d_B(i,j) (d_B + (i) + (j)*ldda)
#define h_R(i,j) (h_R + (i) + (j)*lda)



// A linked list node 
struct Node 
{ 
  int data; 
  struct Node *next; 
}; 
  
void push(struct Node** head_ref, int new_data) { 
  struct Node* new_node = (struct Node*) malloc(sizeof(struct Node)); 
  new_node->data  = new_data; 
  new_node->next = (*head_ref); 
  (*head_ref)    = new_node; 
} 

void deleteNode(struct Node **head_ref, int key) { 
  struct Node* temp = *head_ref, *prev; 
  
  if (temp != NULL && temp->data == key) { 
    *head_ref = temp->next;   // Changed head 
    free(temp);               // free old head 
    return; 
  } 
  
  while (temp != NULL && temp->data != key) { 
    prev = temp; 
    temp = temp->next; 
  } 
  
  if (temp == NULL) return; 
  
  prev->next = temp->next; 
  
  free(temp);  // Free memory 
} 

int findNth(struct Node* head, int n) {
  struct Node *temp = head;

  temp = head;
  for(int i=0; i<n; i++) {
    temp = temp->next;
  }
  
  return temp->data;
  
}

void printList(struct Node *node) { 
  while (node != NULL) { 
    printf(" %d ", node->data); 
    node = node->next; 
  } 
} 

void rMat(int lda, int n, double* h_R, int idx) {
  int i;
  int j;
  
  FILE *file;
  if(idx == 0) {
    file = fopen("input.out", "r");
  } else if(idx == 1) {
    file = fopen("b.out", "r");
  } else if(idx == 2) {
    file = fopen("sigma.out", "r");
  } else {
    file = fopen("s.out", "r");
  }

  if(idx==1) {
    for(i = 0; i<n; i++) {
      h_R[i] = 0;
    }
  }

  for(i = 0; i < lda; i++) {
    for(j = 0; j < n; j++) {
      if (!fscanf(file, "%lf", h_R(i,j)))
	break;
    }
  }
  
  fclose(file);
}

// This function will print a matrix. This takes care of allocating my test array so I don't need to do that in my main function
void pMat(int m, int n, int offset, double *dA, int count, int x, magma_queue_t queue) {
  double *test;
  int ldda; 
  ldda = m;
  ldda   = magma_roundup( m, 32 );  // multiple of 32 by default
  magma_dmalloc_cpu( &test, m*n );

  magma_dgetmatrix(m, n, dA+ldda*offset*count, ldda, test, m, queue);
  for(int i=0; i<m*n; i++) {
    printf("A%d%d(%d,%d)=%lf;\n", x, count, i%m+1, i/m+1, test[i]);
  }
  magma_free( test );
}


int main(int argc, char *argv[]) {

  magma_init();
  real_Double_t magma_time; 

  double *h_R, *tau, *h_B, *Bk, *B0, *Ai, *Di, *sigma, *sig;
  double *d_A, *dtau_magma, *d_B;
  magmaDouble_ptr d_T;

  double **dA_array = NULL;
  double **dtau_array = NULL;
  
  magma_int_t   *dinfo_magma;//, magInfo;
    
  magma_int_t M, N, lda, ldda, n3, NRHS, NB, data_in;
  magma_int_t ione     = 1;
  magma_int_t ISEED[4] = {0,0,0,1};
  //int status = 0;
  
  magma_queue_t queue, queue0;
  double sse, *bestSSE, alpha, beta, numer, denom, RTE, *bestBIC, *bestAIC, RR, PVE;
  int info, one;
  //  int *mask;
  int jdx, idx;
  FILE *fi = fopen("bk.data", "wb");
  one = 1;
  alpha = 1.0;
  beta = 0.0;
  magma_queue_create(0,&queue);
  magma_queue_create(0,&queue0);

  M = atoi(argv[1]);
  N = atoi(argv[2]);
  NRHS = 1;
  data_in = atoi(argv[3]);

  NB = 8;
  
  lda    = M;
  //  n2     = lda*(N+NRHS) * N;
  n3     = lda*(N+NRHS);
  ldda = M;
  ldda   = magma_roundup( M, 32 );  // multiple of 32 by default
  magma_time = magma_sync_wtime(queue);
  
  /* Allocate memory for the matrix */
  magma_dmalloc_cpu( &tau,   N * N );
  magma_dmalloc_cpu( &h_B, N );
  magma_dmalloc_pinned( &h_R,   n3     );
  magma_dmalloc_pinned( &B0, N );
  magma_dmalloc_pinned( &Bk, N );
  magma_dmalloc_pinned( &Ai, N);
  magma_dmalloc_pinned( &Di, N);
  magma_dmalloc_pinned( &sigma, N*N );
  magma_dmalloc_pinned( &sig, 1 );

  magma_dmalloc( &d_A,   ldda*(N+NRHS) * N );
  magma_dmalloc( &d_B,   ldda*(N+NRHS) );
  magma_dmalloc( &d_T,   ( 2*N + magma_roundup( N, 32 ) )*NB );
  magma_dmalloc( &dtau_magma,  N * N );
  
  magma_imalloc( &dinfo_magma,  N );
  
  magma_malloc( (void**) &dA_array,   N * sizeof(double*) );
  magma_malloc( (void**) &dtau_array, N * sizeof(double*) );
  

  //  mask = ( int * )malloc( sizeof(int)*(N) );
  bestSSE = ( double *)malloc( sizeof(double)*(N) );
  bestBIC = ( double *)malloc( sizeof(double)*(N) );
  bestAIC = ( double *)malloc( sizeof(double)*(N) );
  jdx = 0;
  //  mask[0] = 0;
  
  // Linked list for MASK
  struct Node* head = NULL;
  struct Node *temp = NULL;
  for(int i=N-1; i>=0; i--) {
    push(&head, i);
  }
  /*
  if(WATER) {
    printf("List 0=");
    printList(head);
    printf("\n");
  }
  */
  /* Initialize the matrix */

  if(data_in == 1) {
    rMat(lda, N+NRHS, h_R, 0);
    rMat(N, 1, B0, 1);
    rMat(N, N, sigma, 2);
    rMat(1, 1, sig, 3);

  } else {
    lapackf77_dlarnv( &ione, ISEED, &n3, h_R );
  }

  magma_dsetmatrix( M, N+NRHS, h_R, lda,  d_A, ldda, queue );
  //  pMat(M, N+NRHS, 0, d_A, 0, 0, queue);

  // In this version, I am solving the problem N times to save time for having to copy the matrices. Need to figure out best way to do this.
  magma_dset_pointer( dA_array, d_A, ldda, 0, 0, ldda*N, 1, queue );
  magma_dset_pointer( dtau_array, dtau_magma, 1, 0, 0, N, 1, queue );
  info = magma_dgeqrf2_batched(M, N, NRHS, dA_array, ldda, dtau_array, dinfo_magma, 1, queue); // full problem qr and update!

  /********** To set up matrices for the next iteration, I am going to do the following 4 steps*********************
     1. Copy matrix to CPU
     2. Identify best solution
     3. Copy matrix N-nsize times
     4. Transfer new matrix back to GPU
     TODO: Figure out a more optimal way to handle this. I need to figure out *IF* a CUDA kernel is more efficent 
  ******************************************************************************************************************/
  double Md = M;
  for( int nt=N; nt>1; nt--) {
    double Nd = nt;   
    if(nt == N) {
      sse = magma_ddot( M-nt, d_A(nt, nt), 1, d_A(nt, nt), 1, queue);
      bestSSE[N-nt] = sqrt(sse);
      bestBIC[N-nt] = Md*log(sqrt(sse)/Md) + Nd*log(Md);
      bestAIC[N-nt] = Md*log(sqrt(sse)/Md) + 2*Nd;
      jdx = 0;
    }

    // 2. Determine best solution if we are not in the first iteration
    if(nt < N) {
      // Calculate SSE via GPU
      for( int j=0; j<nt+1; j++) {
	sse = magma_ddot( M-nt, d_A(nt, j*(nt+1)+nt), 1, d_A(nt, j*(nt+1)+nt), 1, queue );
	sse = sqrt(sse);
	if( j == 0 ) {
	  bestSSE[N-nt] = sse;
	  bestBIC[N-nt] = Md*log(sqrt(sse)/Md) + Nd*log(Md);
	  bestAIC[N-nt] = Md*log(sqrt(sse)/Md) + 2*Nd;
	  jdx = j;
	} else if( sse < bestSSE[N-nt] ) {
	  bestSSE[N-nt] = sse;
	  bestBIC[N-nt] = Md*log(sqrt(sse)/Md) + Nd*log(Md);
	  bestAIC[N-nt] = Md*log(sqrt(sse)/Md) + 2*Nd;
	  jdx = j;
	}
      }
      idx = findNth(head, jdx);
      deleteNode(&head, idx);
    }
    
    // 3. Manipulate array to set up for the next batch outside of first iteration       
    jdx = jdx*(nt+1);
    magmablas_dlacpy( MagmaUpper, M, nt, d_A(0,jdx), ldda, d_B, ldda, queue0 );    
    magma_dcopy( M, d_A(0,jdx+nt), 1, d_B(0,nt), 1, queue);
    magma_queue_sync(queue0);
    magma_queue_sync(queue);

    for ( int i=0; i<nt+1; i++) {
      magma_dcopymatrix_async( M, i, d_B(0,0), ldda, d_A(0,i*nt), ldda, queue0 );
      magma_dcopymatrix_async( M, nt-i, d_B(0,i+1), ldda, d_A(0,i*(nt+1)), ldda, queue );
      magma_queue_sync(queue0);
      magma_queue_sync(queue);
    }

    if(data_in == 1) {
      magma_dtrsv(MagmaUpper, MagmaNoTrans, MagmaNonUnit, nt, d_B(0,0), ldda, d_B(0,nt), 1, queue0);
      magma_dgetmatrix(nt, 1, d_B(0,nt), ldda, h_B, lda, queue0);      
      magma_queue_sync(queue0);
      // 1. Subtract B-B0
      // 2. Ai=SIGMA*(B-B0) DGEMV
      // 3. Value = (B-B0)*Ai DDOT
      // 3. Transfer Value to CPU
      // 4. RTE=(Value + sigma^2)/sigma^2 
      for(int i=0; i<N; i++) {
	Bk[i] = 0;
      }

      temp = head;
      for(int i=0; i<nt; i++) {
	Bk[temp->data] = h_B[i];
	temp = temp->next;
      }
      
      for(int i=0; i<N; i++) {
	Bk[i] = Bk[i] - B0[i];
      }
      
      if(nt < 10) {
	fprintf(fi, "******************************Starting %d ********************************\n", nt);
	for(int i=0; i<N; i++) {
	  fprintf(fi, "%f\n", Bk[i]);
	}
      }

      // 1. lapack dgemv between Sigma and Bk
      blasf77_dgemv("NoTrans", &N, &N, &alpha, sigma, &N, Bk, &one, &beta, Ai, &one);

      blasf77_dgemv("NoTrans", &N, &N, &alpha, sigma, &N, B0, &one, &beta, Di, &one);

      // 2. dot product
      numer = 0;
      for(int i=0; i<N; i++) {
	numer = Bk[i]*Ai[i]+numer;
      }

      denom = 0;
      for(int i=0; i<N; i++) {
	denom = B0[i]*Di[i]+denom;
      }
      // 3a. RR = dotP/(B0*sigma*B0)
      // 3b. RTE = (dotP+sig^2)/sig^2
      RR = numer/denom;
      RTE = (numer+sig[0]*sig[0])/(sig[0]*sig[0]);
      PVE = 1 - (numer+sig[0]*sig[0])/(denom+sig[0]*sig[0]);
      printf("%d \t %f \t %f \t %f\n", nt, RR, RTE, PVE);
    }

    // 5. Perform dgeqrf2 again
    magma_dset_pointer( dA_array, d_A, ldda, 0, 0, ldda*nt, nt, queue );
    magma_dset_pointer( dtau_array, dtau_magma, 1, 0, 0, nt, nt, queue );
    info = magma_dgeqrf2_batched(M, nt-1, NRHS, dA_array, ldda, dtau_array, dinfo_magma, nt, queue); // full problem qr and update!
    if(DEBUG && info != 0) {
      printf("Error in dgeqrf2_batched!\n");
    }
    magma_queue_sync(queue);
    magma_queue_sync(queue0);
    // Final check when we are on the last iteration
    if(nt == 2) {
      // Calculate SSE via GPU
      Nd = Nd - 1;
      for( int j=0; j<2; j++) {
	sse = magma_ddot( M-1, d_A(1, j*nt+1), 1, d_A(1, j*nt+1), 1, queue );
	sse = sqrt(sse);
	if( j == 0 ) {
	  bestSSE[N-1] = sse;
	  bestBIC[N-1] = Md*log(sqrt(sse)/Md) + Nd*log(Md);
	  bestAIC[N-1] = Md*log(sqrt(sse)/Md) + 2*Nd;
	  jdx = j;
	} else if( sse < bestSSE[N-1] ) {
	  bestSSE[N-1] = sse;
	  bestBIC[N-1] = Md*log(sqrt(sse)/Md) + Nd*log(Md);
	  bestAIC[N-1] = Md*log(sqrt(sse)/Md) + 2*Nd;
	  jdx = j;
	}
      }
      idx = findNth(head, jdx);
      deleteNode(&head, idx);

      jdx = jdx*nt;

      magmablas_dlacpy( MagmaUpper, M, nt, d_A(0,jdx), ldda, d_B, ldda, queue0 );    
      magma_dcopy( M, d_A(0,jdx+nt), 1, d_B(0,nt), 1, queue);
      magma_queue_sync(queue0);
      magma_queue_sync(queue);
      
      if(data_in == 1) {
	magma_dtrsv(MagmaUpper, MagmaNoTrans, MagmaNonUnit, nt, d_A(0,jdx), ldda, d_A(0,jdx+1), 1, queue0);
	magma_dgetmatrix(nt, 1, d_A(0,jdx+1), ldda, h_B, lda, queue0);      
	magma_queue_sync(queue0);
	// 1. Subtract B-B0
	// 2. Ai=SIGMA*(B-B0) DGEMV
	// 3. Value = (B-B0)*Ai DDOT
	// 3. Transfer Value to CPU
	// 4. RTE=(Value + sigma^2)/sigma^2 
	for(int i=0; i<N; i++) {
	  Bk[i] = 0;
	}
	
	temp = head;
	for(int i=0; i<nt-1; i++) {
	  Bk[temp->data] = h_B[i];
	  temp = temp->next;
	}
	
	for(int i=0; i<N; i++) {
	  Bk[i] = Bk[i] - B0[i];
	}

	// 1. lapack dgemv between Sigma and Bk
	blasf77_dgemv("NoTrans", &N, &N, &alpha, sigma, &N, Bk, &one, &beta, Ai, &one);

	blasf77_dgemv("NoTrans", &N, &N, &alpha, sigma, &N, B0, &one, &beta, Di, &one);

	// 2. dot product
	numer = 0;
	for(int i=0; i<N; i++) {
	  numer = Bk[i]*Ai[i]+numer;
	}

	denom = 0;
	for(int i=0; i<N; i++) {
	  denom = B0[i]*Di[i]+denom;
	}
	// 3a. RR = dotP/(B0*sigma*B0)
	// 3b. RTE = (dotP+sig^2)/sig^2
	RR = numer/denom;
	RTE = (numer+sig[0]*sig[0])/(sig[0]*sig[0]);
	PVE = 1 - (numer+sig[0]*sig[0])/(denom+sig[0]*sig[0]);
	printf("%d \t %f \t %f \t %f\n", nt-1, RR, RTE, PVE);
	/*	
	// 1. lapack dgemv between Sigma and Bk
	blasf77_dgemv("NoTrans", &N, &N, &alpha, sigma, &N, Bk, &one, &beta, Ai, &one);
	// 2. dot product
	total = 0;
	for(int i=0; i<N; i++) {
	  total = Bk[i]*Ai[i]+total;
	}
	// 3. RTE = (dotP+sig^2)/sig^2
	RTE = (total+sig[0]*sig[0])/(sig[0]*sig[0]);
	printf("%f\n", RTE);
	*/
      }
    }
  }


  magma_time = magma_sync_wtime(queue) - magma_time;
  //  printf("Time=%f s\n", magma_time);

  FILE *f1 = fopen("sse.data", "wb");
  FILE *f2 = fopen("bic.data", "wb");
  FILE *f3 = fopen("aic.data", "wb");

  for(int i=0; i<N; i++) {
    fprintf(f1, "%f\n", bestSSE[i]);
    fprintf(f2, "%f\n", bestBIC[i]);
    fprintf(f3, "%f\n", bestAIC[i]);
  }

  fclose(f1);
  fclose(f2);
  fclose(f3);

  if(DEBUG) {
    //    for(int i=0; i<N; i++) {
    //printf("mask[%d]=%d\n", i, mask[i]);
    //}
    for(int i=0; i<N; i++) {
      printf("bestSSE[%d]=%f\n", i, bestSSE[i]);
    }
  }
  //  return magInfo;
  return 0;
}
