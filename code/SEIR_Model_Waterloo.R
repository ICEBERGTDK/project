rm(list = ls())
setwd("F:/IC/project/Sar-CoV2/code/")
install.packages("SEIR", repos="http://R-Forge.R-project.org")
library(SEIR)
matrix(c(0, 20, 70, 
         84, 90, 3, 2.6, 1.9, 1, 0.5), ncol = 2)
Sol <- solveSEIR()
names(Sol)
Sol[c(10,50,100,150)]
plot(Sol,"acase")
plot(Sol,"tcase")
plot(Sol, "both")
plot(Sol, "rzero")
plot(Sol, "E")
plot(Sol, "I")

zbreaks <- matrix(c(0,  20,  70,  84,  90, 120, 240, 360,
                    3, 2.6,  1.9, 1,  0.5, 0.5, 1.75, 0.5), ncol = 2)
Sol <- solveSEIR(T=450, r0=zbreaks)
plot(Sol, "rzero")
plot(Sol, "acase")
plot(Sol, "both")
