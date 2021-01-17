#Batch Backward Stepwise Elimination

This repository holds the code for "Backward stepwise elimination: Approximation guarantee, a batched GPU algorithm, and empirical investigation."

##GPUBatchBSE

This directory holds the code for comparing the batched backward stepwise elimination approach with a LAPACK implementation. To use this code please make sure that you have the NVIDIA Compiler NVCC CUDA 9.1 and the latest version of LAPACK and LAPACKE. 
To create the executable use "make" to compile with the makefile. Then run the program "batchSubset M N ENUM" where M and N refer to the number of rows and the number of columns in the desired problem, and ENUM is the stopping point of backward stepwise selection.

For example, `./batchSubset 1000 600 0` will execute the same problem size used in the paper.