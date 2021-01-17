#!/bin/bash

rho=0.70 # Changed from 0.9 for last experiments
SNR=(0.05 0.09 0.14 0.25 0.42 0.71 1.22 2.07 3.52 6.0) # Changed from 5
m=500
n=100
beta=1
#s=5 #Changed from 210 to start halfway through.
COUNT=1

s=5
sK=0

while [ $s -le 10 ]; do
    mkdir ./$s
    sed -i 's/$s ##/'"$s ##"'/g' ./fast.R
#    sed -i 's/$m ##/'"${m[s]} #"'/g' ./master.R
#    sed -i 's/$n ##/'"${n[s]} #"'/g' ./master.R
    while [ $sK -le 9 ]; do #changed from 310
	mkdir ./$s/$sK
	sed -i 's/$snr ##/'"${SNR[sK]} ##"'/g' ./fast.R
	echo "Beginning SNR=${SNR[sK]}"
	Rscript ./fast.R > ./$s/$sK/lasso.txt
	paste -d ", " 1outX.out 1outRISK.out 1outY.out 1outPVE.out > ./$s/$sK/fss.dat
	paste -d ", " 2outX.out 2outRISK.out 2outY.out 2outPVE.out > ./$s/$sK/relaxedlasso.dat
	paste -d ", " 3outX.out 3outRISK.out 3outY.out 3outPVE.out > ./$s/$sK/lasso.dat
	mv *bic.out ./$s/$sK
	mv *aic.out  ./$s/$sK
	mv "riskPlot.pdf" ./$s/$sK/riskPlot.pdf

	while [ $COUNT -le 5 ]; do
	    paste -d " " "$COUNT"x.out "$COUNT"y.out > input.out
	    mv "$COUNT"b.out b.out
	    mv "$COUNT"sigma.out sigma.out
	    mv "$COUNT"s.out s.out
	    ./backwards.opt $m $n 1 > tmp.dat	    
	    mv b.out "$COUNT"b.out
	    mv sigma.out "$COUNT"sigma.out
	    mv s.out "$COUNT"s.out
	    if [ $COUNT -eq 1 ]; then
		awk '{print $1}' tmp.dat > ./$s/$sK/nnz.dat
		awk '{print $2}' tmp.dat > ./$s/$sK/rr.dat
 		awk '{print $3}' tmp.dat > ./$s/$sK/rte.dat
		awk '{print $4}' tmp.dat > ./$s/$sK/pve.dat

		mv sse.data ./$s/$sK/sse.dat
		mv bic.data ./$s/$sK/bic.dat
		mv aic.data ./$s/$sK/aic.dat
		mv "$COUNT"s.out ./$s/$sK/s.out
		mv ./$s/$sK/lasso"$COUNT"aic.out ./$s/$sK/lassoAIC.dat
		mv ./$s/$sK/fss"$COUNT"aic.out ./$s/$sK/fssAIC.dat
		mv ./$s/$sK/lasso"$COUNT"bic.out ./$s/$sK/lassoBIC.dat
		mv ./$s/$sK/fss"$COUNT"bic.out ./$s/$sK/fssBIC.dat
		mv ./$s/$sK/relaxedlasso"$COUNT"aic.out ./$s/$sK/relaxedlassoAIC.dat
		mv ./$s/$sK/relaxedlasso"$COUNT"bic.out ./$s/$sK/relaxedlassoBIC.dat
	    else
		awk '{print $2}' tmp.dat > t.dat
		paste -d " " t.dat ./$s/$sK/rr.dat > tmp2.dat
		mv tmp2.dat ./$s/$sK/rr.dat

		awk '{print $3}' tmp.dat > t.dat
		paste -d " " t.dat ./$s/$sK/rte.dat > tmp2.dat
		mv tmp2.dat ./$s/$sK/rte.dat

		awk '{print $4}' tmp.dat > t.dat
		paste -d " " t.dat ./$s/$sK/pve.dat > tmp2.dat
		mv tmp2.dat ./$s/$sK/pve.dat

		paste -d " " sse.data ./$s/$sK/sse.dat > tmp2.dat
		mv tmp2.dat ./$s/$sK/sse.dat
		paste -d " " bic.data ./$s/$sK/bic.dat > tmp2.dat
		mv tmp2.dat ./$s/$sK/bic.dat
		paste -d " " aic.data ./$s/$sK/aic.dat > tmp2.dat
		mv tmp2.dat ./$s/$sK/aic.dat

		paste -d " " ./$s/$sK/lassoAIC.dat ./$s/$sK/lasso"$COUNT"aic.out > ./$s/$sK/tmp.dat
		mv ./$s/$sK/tmp.dat ./$s/$sK/lassoAIC.dat
		paste -d " " ./$s/$sK/fssAIC.dat ./$s/$sK/fss"$COUNT"aic.out > ./$s/$sK/tmp.dat
		mv ./$s/$sK/tmp.dat ./$s/$sK/fssAIC.dat
		paste -d " " ./$s/$sK/lassoBIC.dat ./$s/$sK/lasso"$COUNT"bic.out > ./$s/$sK/tmp.dat
		mv ./$s/$sK/tmp.dat ./$s/$sK/lassoBIC.dat
		paste -d " " ./$s/$sK/fssBIC.dat ./$s/$sK/fss"$COUNT"bic.out > ./$s/$sK/tmp.dat
		mv ./$s/$sK/tmp.dat ./$s/$sK/fssBIC.dat

		paste -d " " ./$s/$sK/relaxedlassoAIC.dat ./$s/$sK/relaxedlasso"$COUNT"aic.out > ./$s/$sK/tmp.dat
		mv ./$s/$sK/tmp.dat ./$s/$sK/relaxedlassoAIC.dat
		paste -d " " ./$s/$sK/relaxedlassoBIC.dat ./$s/$sK/relaxedlasso"$COUNT"bic.out > ./$s/$sK/tmp.dat
		mv ./$s/$sK/tmp.dat ./$s/$sK/relaxedlassoBIC.dat
	    fi
	    ((COUNT++))
	done
	COUNT=1
	
#	awk '{sum=0; for(i=1; i<=NF; i++) {sum+=$i}; sum/=NF; print sum}' ./$s/$sK/nnz.dat > tmp3.dat
#	mv tmp3.dat ./$s/$sK/nnz.dat
	awk '{sum=0; for(i=1; i<=NF; i++) {sum+=$i}; sum/=NF; print sum}' ./$s/$sK/rr.dat > tmp3.dat
	mv tmp3.dat ./$s/$sK/avgrr.dat
	awk '{sum=0; for(i=1; i<=NF; i++) {sum+=$i}; sum/=NF; print sum}' ./$s/$sK/rte.dat > tmp3.dat
	mv tmp3.dat ./$s/$sK/avgrte.dat
	awk '{sum=0; for(i=1; i<=NF; i++) {sum+=$i}; sum/=NF; print sum}' ./$s/$sK/pve.dat > tmp3.dat
	mv tmp3.dat ./$s/$sK/avgpve.dat

	paste -d " " ./$s/$sK/nnz.dat ./$s/$sK/avgrr.dat ./$s/$sK/avgrte.dat ./$s/$sK/avgpve.dat > ./$s/$sK/bse.dat

	awk 'NR == 1 || $2 < min {line = $0; min = $2; bst=NR}END{print line}' ./$s/$sK/bse.dat >> ./$s/bse.out

 	awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/aic.dat > ./$s/$sK/avgAIC.dat
        awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/bic.dat > ./$s/$sK/avgBIC.dat
	awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' ./$s/$sK/avgAIC.dat >> ./$s/bseAIC.out
	awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' ./$s/$sK/avgBIC.dat >> ./$s/bseBIC.out
	
	sed -i 's/,/, /g' ./$s/$sK/fss.dat
	sed -i 's/,/, /g' ./$s/$sK/lasso.dat
	awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/lassoAIC.dat > ./$s/$sK/avglassoAIC.dat
        awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/lassoBIC.dat > ./$s/$sK/avglassoBIC.dat
	awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/fssAIC.dat > ./$s/$sK/avgfssAIC.dat
        awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/fssBIC.dat > ./$s/$sK/avgfssBIC.dat

	#awk 'NR == 1 || $2 < min {line = $0; min = $2}END{print line}' ./$s/$sK/fss.dat >> ./$s/fss.out
	#awk 'NR == 1 || $2 < min {line = $0; min = $2}END{print line}' ./$s/$sK/lasso.dat >> ./$s/lasso.out	

	awk 'NR == 1 || $2 < min {line = $0; min = $2; bst=NR}END{print line}' ./$s/$sK/fss.dat >> ./$s/fss.out
	awk 'NR == 1 || $2 < min {line = $0; min = $2; bst=NR}END{print line}' ./$s/$sK/lasso.dat >> ./$s/lasso.out

	awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' ./$s/$sK/avgfssAIC.dat >> ./$s/fssAIC.out
	awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' ./$s/$sK/avgfssBIC.dat >> ./$s/fssBIC.out
	awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' ./$s/$sK/avglassoAIC.dat >> ./$s/lassoAIC.out	
	awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' ./$s/$sK/avglassoBIC.dat >> ./$s/lassoBIC.out		

	sed -i 's/,/, /g' ./$s/$sK/relaxedlasso.dat
	awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/relaxedlassoAIC.dat > ./$s/$sK/avgrelaxedlassoAIC.dat
        awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/relaxedlassoBIC.dat > ./$s/$sK/avgrelaxedlassoBIC.dat

	#awk 'NR == 1 || $2 < min {line = $0; min = $2}END{print line}' ./$s/$sK/relaxedlasso.dat >> ./$s/relaxedlasso.out
	awk 'NR == 1 || $2 < min {line = $0; min = $2; bst=NR}END{print line}' ./$s/$sK/relaxedlasso.dat >> ./$s/relaxedlasso.out
	
	awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' ./$s/$sK/avgrelaxedlassoAIC.dat >> ./$s/relaxedlassoAIC.out	
	awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' ./$s/$sK/avgrelaxedlassoBIC.dat >> ./$s/relaxedlassoBIC.out	

	awk '{print $1}' ./$s/$sK/s.out >> ./$s/s.out

	rm *.out
	sed -i 's/'"${SNR[sK]} ##"'/$snr ##/g' ./fast.R
	((sK+=1)) # Changed from +=5
    done
    matlab -nodisplay -nodesktop -nosplash -r "fastSNR2('/home/bsauk/Documents/research/4thyear/update/backward/cudaVersion/comparative/$s'); exit;"
    sK=0 # changed from 5
    sed -i 's/'"$s ##"'/$s ##/g' ./fast.R
    ((s+=5))
done
