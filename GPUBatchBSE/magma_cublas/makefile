all: compare_dgeqrf.opt
	./compare_dgeqrf.opt 1000 400 

%.out: %.cpp
	g++ -O0 -g -fPIC -D DEBUG=1 -DNDEBUG -DADD_ -Wall -std=c++11 -DHAVE_CUBLAS -DMIN_CUDA_ARCH=350 -I/usr/local/cuda-9.1/include -I /home/bsauk/Personal/magma-2.5.0/include  \
	-L /home/bsauk/Personal/magma-2.5.0/lib -lmagma -L/usr/local/cuda-9.1/lib64 -L/usr/local/openblas/lib -lopenblas -lcublas -lcusparse -lcudart -lcudadevrt $< -o $@

%.opt: %.cpp
	g++ -O3 -fPIC -DADD_ -Wall -std=c++11 -DHAVE_CUBLAS -DMIN_CUDA_ARCH=350 -I/usr/local/cuda-9.1/include -I /home/bsauk/Personal/magma-2.5.0/include  \
	-L /home/bsauk/Personal/magma-2.5.0/lib -lmagma -L/usr/local/cuda-9.1/lib64 -L/usr/local/openblas/lib -lopenblas -lcublas -lcusparse -lcudart -lcudadevrt $< -o $@

clean: 
	rm -rf dgeqrf2_batched.out
	rm -rf *.o
	rm -rf *.out
	rm -rf *.opt
