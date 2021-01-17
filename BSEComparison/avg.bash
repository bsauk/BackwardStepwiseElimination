size=(low medium)
k=0
sK=0
COUNT=1

while [ $k -le 1 ]; do
    s=${size[k]}
    while [ $sK -le 9 ]; do
	while [ $COUNT -le 10 ]; do
	    if [ $COUNT -eq 1 ]; then
                mv ./$s/$sK/relaxedlasso"$COUNT"aic.out ./$s/$sK/relaxedlassoAIC.dat
                mv ./$s/$sK/relaxedlasso"$COUNT"bic.out ./$s/$sK/relaxedlassoBIC.dat
            else
                paste -d " " ./$s/$sK/relaxedlassoAIC.dat ./$s/$sK/relaxedlasso"$COUNT"aic.out > ./$s/$sK/tmp.dat
                mv ./$s/$sK/tmp.dat ./$s/$sK/relaxedlassoAIC.dat
                paste -d " " ./$s/$sK/relaxedlassoBIC.dat ./$s/$sK/relaxedlasso"$COUNT"bic.out > ./$s/$sK/tmp.dat
                mv ./$s/$sK/tmp.dat ./$s/$sK/relaxedlassoBIC.dat
            fi
            ((COUNT++))
	done
	COUNT=1
        awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/relaxedlassoAIC.dat > ./$s/$sK/avgrelaxedlassoAIC.dat
        awk '{sum = 0; for (i = 1; i <= NF; i++) sum += $i; sum /= NF; print sum}' ./$s/$sK/relaxedlassoBIC.dat > ./$s/$sK/avgrelaxedlassoBIC.dat

        awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' ./$s/$sK/avgrelaxedlassoAIC.dat >> ./$s/relaxedlassoAIC.out
        awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' ./$s/$sK/avgrelaxedlassoBIC.dat >> ./$s/relaxedlassoBIC.out


	((sK++))
    done
    sK=0
    matlab -nodisplay -nodesktop -nosplash -r "bicSNR('/home/bsauk/Documents/research/4thyear/update/backward/cudaVersion/comparative/$s'); exit;"
    matlab -nodisplay -nodesktop -nosplash -r "aicSNR('/home/bsauk/Documents/research/4thyear/update/backward/cudaVersion/comparative/$s'); exit;"
    ((k++))
done
