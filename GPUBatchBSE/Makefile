include /home/bsauk/Personal/lapack-3.6.0/make.inc

LIBS = /usr/local/cuda-9.1/lib64

LIBRARIES=/home/bsauk/Personal/lapack-3.6.0/$(LAPACKELIB) /home/bsauk/Personal/lapack-3.6.0/$(LAPACKLIB) /home/bsauk/Personal/lapack-3.6.0/librefblas.a

all: batchSubset

batchSubset: batchSubset.o gold.o
	gfortran $^ -o $@ $(LIBRARIES) -L$(LIBS) -lcuda -lcublas -lcudart

%.o: %.cu
	nvcc -c -g -G -I. -I/home/bsauk/Personal/lapack-3.6.0/LAPACKE/include -o $@ $<

clean:
	rm *.o
	rm batchSubset
