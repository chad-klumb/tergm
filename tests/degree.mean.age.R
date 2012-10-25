library(tergm)
opttest({

logit<-function(p)log(p/(1-p))

# NB:  duration.matrix function no longer exists in ergm package
#print.sim.stats<-function(dynsim,m,d){
#  t.score<-function(x,m) (mean(x)-m)/sqrt(apply(cbind(x),2,var)/effectiveSize(mcmc(x)))
#  target.stats.sim<-apply(dynsim$stats.form,2,mean)
#  durations<-duration.matrix(dynsim)$duration
#  cat('Edge count:\n   Target:',m,', Simulated:',target.stats.sim,', t:', t.score(dynsim$stats.form,m) ,'\n')
#  cat('Duration:\n   Target:',d,', Simulated:',mean(durations),', t:', t.score(durations,d) ,'\n')
#}

coef.form.f<-function(coef.diss,density) -log(((1+exp(coef.diss))/(density/(1-density)))-1)

S<-10000

n<-60
target.stats<-edges<-60
duration<-12
coef.diss<-logit(1-1/duration)

### Undirected

dyads<-n*(n-1)/2
density<-edges/dyads
coef.form<-coef.form.f(coef.diss,density)

cat("\nUndirected:\n")

g0<-network.initialize(n,dir=FALSE)

g0 %v% "a" <- rep(1:2, c(20,40))

print(coef.form)
print(coef.diss)

# Simulate from the fit.
dynsim<-simulate(g0,formation=~edges,dissolution=~edges,coef.form=coef.form,coef.diss=coef.diss,time.burnin=S, time.slices=S,verbose=TRUE,output="stats",
                 monitor=~edges+mean.age+
                 degree.mean.age(1:3)+degrange.mean.age(1:2,3:4)+degrange.mean.age(1:2)+
                 degree.mean.age(1:3,"a")+degrange.mean.age(1:2,3:4,"a")+degrange.mean.age(1:2,by="a"))

targets <- c(60,12,rep(12,21))

test <- approx.hotelling.diff.test(dynsim,mu0=targets)

if(test$p.value < 0.05){
  print(test)
  stop("At least one statistic differs from target.")
}
               

#dynsim<-simulate(g0,formation=~edges,dissolution=~edges+edges.ageinterval(7),coef.form=coef.form,coef.diss=c(logit(0.8),logit(0.8)-logit(0.7)),time.slices=S,verbose=TRUE,statsonly=TRUE,monitor=~edges+edges.ageinterval(1:40,2:41))


#print.sim.stats(dynsim,target.stats,duration)
#dynsim<-simulate(g0,formation=~edges,dissolution=~edges,coef.form=coef.form,coef.diss=coef.diss,time.slices=S,verbose=TRUE,statsonly=TRUE,monitor=~degrange(0:2,2:4,"a"))
}, "degree mean age terms simulation")