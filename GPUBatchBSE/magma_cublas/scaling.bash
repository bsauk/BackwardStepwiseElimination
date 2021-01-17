#!/bin/bash

m=1500
n=400
COUNT=1
while [ $n -le 400 ]; do
    echo "$m x $n" >> dgeqrf_out.txt
    while [ $COUNT -le 5 ]; do 
	/home/bsauk/Documents/research/4thyear/batch/magma_cublas/compare_dgeqrf.opt $m $n >> dgeqrf_out.txt
	((COUNT++))
    done
    COUNT=1
    ((n-=20))
done
