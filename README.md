# Batch Backward Stepwise Elimination

This repository holds the code for "Backward stepwise elimination: Approximation guarantee, a batched GPU algorithm, and empirical investigation."

## src
These files were the ones that were created to perform batched backward stepwise elimination with MAGMA. After downloading MAGMA, please copy these files into the ./magma-2.5.0/src directory and then proceed with the MAGMA installation. These files
are needed to run the backwards.opt algorithm that is used in the two other directories.

## GPUBatchBSE

This directory is used to perform the comparative experiments between backward stepwise elimination, forward selection, the lasso, and the relaxed lasso. The R code is based on Hastie et al. 2017, "Extended Comparisons of Best Subset Selection, Forward Selection, and the Lasso." 
To use this code, please ensure that you have the following software installed:

1. NVCC CUDA 9.1
2. MAGMA-2.5 
3. OpenBLAS
4. MATLAB (Optional for visualizing results)

To execute this code, first change `MAGMADIR` in the makefile to point towards your installed version of MAGMA. Then create the executable by running, "make opt." Then to run the experiment set `m` and `n` inside of the fastCompare.bash file. This file will modify the R script which runs three of the tests, and run the backwards.opt file that is created
via the makefile. After running the results, use the matlab files to visualize the results from the different experiments. Alternatively, look at the text files produced from the executable files.

Please see the fastCompare.bash file for comments related to the different operations. This file allows for the automation of the entire testing procedure.

