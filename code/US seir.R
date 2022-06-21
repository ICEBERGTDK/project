#United States
rm(list = ls())

N = 332915074
E = 0
I = 1
S = N-I
R = 0


r = 20
B = 0.03
a = 0.1
y = 0.1


T = 365

 
for (i in 1:(T-1)){

  S[i+1] = S[i] - r*B*S[i]*I[i]/N
  E[i+1] = E[i] + r*B*S[i]*I[i]/N - a*E[i]
  I[i+1] = I[i] + a*E[i] - y*I[i]
  R[i+1] = R[i] + y*I[i]

}

result <- data.frame(S, E, I, R)

#View(result)

X_lim <- seq(1,T,by=1)

plot(S~X_lim, pch=15, col="DarkTurquoise", main = "SEIR Model(US)", type = "l", xlab = "T", ylab = "people", xlim = c(0,T), ylim = c(0,332915074))
lines(S, col="DeepPink", lty=1) 
lines(E, col="DarkTurquoise", lty=1)
lines(I, col="RosyBrown", lty=1)
lines(R, col="green", lty=1)
legend(300,100000000,c("S","E","I","R"),col=c("DeepPink","DarkTurquoise","RosyBrown","green"),text.col=c("DeepPink","DarkTurquoise","RosyBrown","green"),lty=c(1,1,1,1))
