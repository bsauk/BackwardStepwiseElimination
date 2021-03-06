library(bestsubset)
set.seed(0)
n= $m ##
p= $n ##
nval = n
rhoK = 0
sK =  $s ##
snrK = $snr ##
reps = 5

# Check for gurobi package
if (!require("gurobi",quietly=TRUE)) {
  stop("Package gurobi not installed (required here)!")
}

# Regression functions: lasso, forward stepwise, and best subset selection
reg.funs = list()

reg.funs[["Stepwise"]] = function(x,y) fs(x,y,intercept=FALSE)
reg.funs[["Relaxed lasso"]] = function(x,y) lasso(x,y,intercept=FALSE,
                                                  nrelax=5,nlam=50)
reg.funs[["Lasso"]] = function(x,y) lasso(x,y,intercept=FALSE,nlam=50)

for (j in 1:reps) {
    sim.obj.data = sim.xy(n, p, nval, rho=rhoK, s=sK, beta.type=3, snr=snrK)
    fnx <- paste(j, "x.out", sep="")
    fny <- paste(j, "y.out", sep="")
    fnb <- paste(j, "b.out", sep="")
    fnS <- paste(j, "sigma.out", sep="")
    fns <- paste(j, "s.out", sep="")
    write.table(sim.obj.data$x, file=fnx, row.names=FALSE, col.names=FALSE)
    write.table(sim.obj.data$y, file=fny, row.names=FALSE, col.names=FALSE) 
    write.table(sim.obj.data$beta, file=fnb, row.names=FALSE, col.names=FALSE) 
    write.table(sim.obj.data$Sigma, file=fnS, row.names=FALSE, col.names=FALSE) 
    write.table(sim.obj.data$sigma, file=fns, row.names=FALSE, col.names=FALSE)
}

set.seed(0)
sim.obj.hisnr = sim.master(n,p,nval,reg.funs=reg.funs,nrep=reps,seed=0,
                           beta.type=3,s=sK,rho=rhoK,snr=snrK,verbose=TRUE)

#"High runtime"
sim.obj.hisnr$runtime

rel.err = vector(mode="list", length=3)
prop.err = vector(mode="list", length=3)
risk.err = vector(mode="list", length=3)
nzs.ave = vector(mode="list", length=3)
rel.ave = vector(mode="list", length=3)
prop.ave = vector(mode="list", length=3)
risk.ave = vector(mode="list", length=3)

for (j in 1:3) {
    risk.err[[j]] = sim.obj.hisnr$risk[[j]]/sim.obj.hisnr$risk.null
    rel.err[[j]] = sim.obj.hisnr$err.test[[j]]/sim.obj.hisnr$sigma^2
    prop.err[[j]] = sim.obj.hisnr$prop[[j]]
}

for(j in 1:3) {
      xStat = sim.obj.hisnr$nzs[[j]]
      tmp = n*log(sqrt(sim.obj.hisnr$err.train[[j]])/n)+xStat*log(n)
      tmp2 = n*log(sqrt(sim.obj.hisnr$err.train[[j]])/n)+xStat*2
      if(j==1) {
      	       nm = "fss"	
      } else if(j==2) {
               nm = "relaxedlasso"
      } else {
      	       nm = "lasso"
      }
      for(k in 1:reps) {
      	    bic <- matrix(tmp[k, 1:ncol(xStat)], nrow=ncol(xStat))
	    aic <- matrix(tmp2[k, 1:ncol(xStat)], nrow=ncol(xStat))
      	    fnBIC <- paste(nm, k, "bic.out", sep="")
      	    fnAIC <- paste(nm, k, "aic.out", sep="")
      	    write.table(bic, file=fnBIC, row.names=FALSE, col.names=FALSE)
     	    write.table(aic, file=fnAIC, row.names=FALSE, col.names=FALSE)
     }
}

for (j in 1:3) {
    risk.ave[[j]] = colMeans(risk.err[[j]], na.rm=TRUE)
    prop.ave[[j]] = colMeans(prop.err[[j]], na.rm=TRUE)
    rel.ave[[j]] = colMeans(rel.err[[j]], na.rm=TRUE)
    nzs.ave[[j]] = colMeans(sim.obj.hisnr$nzs[[j]], na.rm=TRUE)    
}


for(j in 1:3) {
      fnXX <- paste(j, "outX.out", sep="")
      fnYY <- paste(j, "outY.out", sep="")
      fnRISK <- paste(j, "outRISK.out", sep="")
      fnPROP <- paste(j, "outPVE.out", sep="")
      write.table(nzs.ave[[j]], file=fnXX, row.names=FALSE, col.names=FALSE)
      write.table(rel.ave[[j]], file=fnYY, row.names=FALSE, col.names=FALSE)
      write.table(risk.ave[[j]], file=fnRISK, row.names=FALSE, col.names=FALSE)
      write.table(prop.ave[[j]], file=fnPROP, row.names=FALSE, col.names=FALSE)
}
plot(sim.obj.hisnr, what="risk", main="Risk Plot", legend=TRUE, make.pdf=TRUE,  fig.dir=".", file.name="riskPlot", h=4, w=4)
