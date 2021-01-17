extern "C" float goldSubset(int m, int n, int r, unsigned long batchSize);
extern "C" float testGold(int m, int n, int r, int batchSize);
void matrixInit(int in, double **A, double **B, int batchSize, int lim1, int lim2);
