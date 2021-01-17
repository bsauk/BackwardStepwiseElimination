#!/bin/bash

s=10
k=0
while [ $s -le 70 ]; do #changed from 310
    while [ $k -le 9 ]; do
#    matlab -nodisplay -nodesktop -nosplash -r "sseSNR('/home/bsauk/Documents/research/4thyear/update/backward/cudaVersion/comparative/$s'); exit;" 
	matlab -nodisplay -nodesktop -nosplash -r "plotRR('/home/bsauk/Documents/research/4thyear/update/backward/cudaVersion/comparative/$s/$k'); exit;" 
	((k+=1))
    done
    k=0
    ((s+=10))
done

