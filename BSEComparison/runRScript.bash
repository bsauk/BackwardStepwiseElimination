#!/bin/bash

rho=0.7
sK=5
beta=1
snr=1
s=10 #Changed from 10 to start halfway through.
COUNT=1
K=1

while [ $s -le 310 ]; do #changed from 310
    mkdir ./$s
    sed -i 's/$sK/'"$s ##"'/g' ./master.R
    while [ $sK -le 70 ]; do  #changed from 70
	mkdir ./$s/$sK
	snr=$( echo "($sK/10)" | bc -l )
	sed -i 's/$snr/'"$snr #"'/g' ./master.R
	echo "Beginning SNR=$snr"
	Rscript ./master.R > ./$s/$sK/lasso.txt
	paste -d ", " 1outX.out 1outY.out > ./$s/$sK/lasso.dat
	paste -d ", " 2outX.out 2outY.out > ./$s/$sK/fss.dat
	mv *bic.out ./$s/$sK
	mv *aic.out  ./$s/$sK

	while [ $COUNT -le 10 ]; do
	    if [ $COUNT -eq 1 ]; then
		mv ./$s/$sK/lasso"$COUNT"aic.out ./$s/$sK/lassoAIC.dat
		mv ./$s/$sK/fss"$COUNT"aic.out ./$s/$sK/fssAIC.dat
		mv ./$s/$sK/lasso"$COUNT"bic.out ./$s/$sK/lassoBIC.dat
		mv ./$s/$sK/fss"$COUNT"bic.out ./$s/$sK/fssBIC.dat
	    else
		paste -d " " ./$s/$sK/lassoAIC.dat ./$s/$sK/lasso"$COUNT"aic.out > ./$s/$sK/tmp.dat
		mv ./$s/$sK/tmp.dat ./$s/$sK/lassoAIC.dat
		paste -d " " ./$s/$sK/fssAIC.dat ./$s/$sK/fss"$COUNT"aic.out > ./$s/$sK/tmp.dat
		mv ./$s/$sK/tmp.dat ./$s/$sK/fssAIC.dat
		paste -d " " ./$s/$sK/lassoBIC.dat ./$s/$sK/lasso"$COUNT"bic.out > ./$s/$sK/tmp.dat
		mv ./$s/$sK/tmp.dat ./$s/$sK/lassoBIC.dat
		paste -d " " ./$s/$sK/fssBIC.dat ./$s/$sK/fss"$COUNT"bic.out > ./$s/$sK/tmp.dat
		mv ./$s/$sK/tmp.dat ./$s/$sK/fssBIC.dat
	    fi
	    ((COUNT++))
	done
	COUNT=1
	awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/lassoAIC.dat > ./$s/$sK/avglassoAIC.dat
        awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/lassoBIC.dat > ./$s/$sK/avglassoBIC.dat
	awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/fssAIC.dat > ./$s/$sK/avgfssAIC.dat
        awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/fssBIC.dat > ./$s/$sK/avgfssBIC.dat
	
	awk 'NR == 1 || $2 < min {line = $0; min = $2}END{print line}' ./$s/$sK/avgfssAIC.dat >> ./$s/fssAIC.out
	awk 'NR == 1 || $2 < min {line = $0; min = $2}END{print line}' ./$s/$sK/avgfssBIC.dat >> ./$s/fssBIC.out
	awk 'NR == 1 || $2 < min {line = $0; min = $2}END{print line}' ./$s/$sK/avglassoAIC.dat >> ./$s/lassoAIC.out	
	awk 'NR == 1 || $2 < min {line = $0; min = $2}END{print line}' ./$s/$sK/avglassoBIC.dat >> ./$s/lassoBIC.out	

	awk 'NR == 1 || $2 < min {line = $0; min = $2}END{print line}' ./$s/$sK/fss.dat >> ./$s/fss.out
	awk 'NR == 1 || $2 < min {line = $0; min = $2}END{print line}' ./$s/$sK/lasso.dat >> ./$s/lasso.out	

	rm *.out	
	sed -i 's/'"$snr #"'/$snr/g' ./master.R
	((sK+=5))
    done
    sK=5
    sed -i 's/'"$s ##"'/$sK/g' ./master.R
    ((s+=50))
done
