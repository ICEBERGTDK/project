# Germany
# Infected <- c(16, 18, 21, 26, 53, 66, 117, 150, 188, 240, 349, 534, 684, 847, 1112, 1460, 1884, 2369, 3062, 3795, 4838, 6012, 7156, 8198, 10999)

# UK
Infected <- c(2,2,3,3,4,8,8,9,13,13,19,23,35,40,51,85,114,160,206,271,321,373,456,590,797,1061,1391,1543,1950,2626,3269)
Day <- 1:(length(Infected))
N <- 68207114 # pupulation of the UK

old <- par(mfrow = c(1, 2))
plot(Day, Infected, type ="b")
plot(Day, Infected, log = "y")
abline(lm(log10(Infected) ~ Day))
title("Confirmed infections COVID-19 in the UK", outer = TRUE, line = -2)

SEIR <- function(time, state, parameters) {
  par <- as.list(c(state, parameters))
  with(par, {
    dS <- -beta/N * I * S
    dE <- beta * S * I - delta * E
    dI <- delta * E - gamma * I
    dR <- gamma * I
    list(c(dS, dE, dI, dR))
    })
}

library(deSolve)
init <- c(S = N-Infected[1], E = N-2*Infected[1], I = Infected[1], R = 0)
RSS <- function(parameters) {
  names(parameters) <- c("beta", "gamma")
  out <- ode(y = init, times = Day, func = SEIR, parms = parameters)
  fit <- out[ , 3]
  sum((Infected - fit)^2)
}
 
Opt <- optim(c(0.5, 0.5), RSS, method = "L-BFGS-B", lower = c(0, 0), upper = c(1, 1)) # optimize with some sensible conditions
Opt$message
## [1] "CONVERGENCE: REL_REDUCTION_OF_F <= FACTR*EPSMCH"
 
Opt_par <- setNames(Opt$par, c("beta", "gamma"))
print(Opt_par)
 
t <- 1:90 # time in days
fit <- data.frame(ode(y = init, times = t, func = SEIR, parms = Opt_par))
col <- 1:3 # colour
print(fit) 
matplot(fit$time, fit[ , 2:4], type = "l", xlab = "Day", ylab = "Number of subjects", lwd = 2, lty = 1, col = col)
 matplot(fit$time, fit[ , 2:4], type = "l", xlab = "Day", ylab = "Number of subjects", lwd = 2, lty = 1, col = col, log = "y")

points(Day, Infected)
legend("bottomright", c("Susceptibles", "exposed", "Infecteds", "Recovereds"), lty = 1, lwd = 2, col = col, inset = 0.05)
title("Predicted Cases 2019-nCoV UK (worst case)", outer = TRUE, line = -2)

