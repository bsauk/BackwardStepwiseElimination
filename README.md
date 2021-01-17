# Batch Backward Stepwise Elimination

This repository holds the code for "Backward stepwise elimination: Approximation guarantee, a batched GPU algorithm, and empirical investigation."

## GPUBatchBSE

This directory holds the code for comparing the batched backward stepwise elimination approach with a LAPACK implementation. To use this code please make sure that you have the NVIDIA Compiler NVCC CUDA 9.1 and the latest version of LAPACK and LAPACKE. 
To create the executable use "make" to compile with the makefile. Then run the program "batchSubset M N ENUM" where M and N refer to the number of rows and the number of columns in the desired problem, and ENUM is the stopping point of backward stepwise selection.

For example, `./batchSubset 1000 600 0` will execute the same problem size used in the paper.

## BSEComparison

This directory is used to perform the comparative experiments between backward stepwise elimination, forward selection, the lasso, and the relaxed lasso. The R code is based on Hastie et al. 2017, "Extended Comparisons of Best Subset Selection, Forward Selection, and the Lasso." 
To use this code, please ensure that you have the following software installed:

1. NVCC CUDA 9.1
2. MAGMA-2.5 
3. OpenBLAS
4. MATLAB (Optional for visualizing results)

To execute this code, first change `MAGMADIR` in the makefile to point towards your installed version of MAGMA. Then create the executable by running, "make opt." Then to run the experiment set `m` and `n` inside of the fastCompare.bash file. This file will modify the R script which runs three of the tests, and run the backwards.opt file that is created
via the makefile. After running the results, use the matlab files to visualize the results from the different experiments. Alternatively, look at the text files produced from the executable files.

