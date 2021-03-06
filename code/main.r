
#' @param S0 Integer, number of initially susceptible individuals.
#' @param E0 Integer, number of initially exposed individuals.
#' @param I0 Integer, number of initially infectious individuals.
#' @param N Integer, population size.
#' @param tau Integer, number of days to simulate over.
#' @param beta vector with elements for each column of \code{X} which specify the 
#' transmission rate over time.
#' @param X The design matrix corresponding to the intensity process over epidemic time.
#' @param rateE The rate of the exponentially distributed time spent in the latent period.
#' @param infPeriodSpec A character indicating which model for the infectious period
#' will be used. 
#' @param infExpParams A \emph{list} giving parameters specific to the exponentially
#' distributed infectious period. See details for specifics.
#' @param infPSParams A \emph{list} giving parameters specific to the path-specific
#' distributed infectious period. See details for specifics.
#' @param infIDDParams A \emph{list} giving parameters specific to the infectious
#' duration-dependent infectious period. See details for specifics.
#' 
#' @return A list with elements \code{N, S0, E0, I0, S, E, I, R, Estar, Istar, Rstar},
#' which provide the simulated number of individuals in each compartment over time 
#' (\code{S, E, I, R}) and transitioning into each compartment over epidemic time 
#' (\code{Estar, Istar, Rstar}). Also returns the initial conditions as specified
#' by the user.
#' 
#' @details \code{simSEIR} simulates an epidemic according to the stochastic SEIR
#' chain binomial formulation. Epidemics may be simulated according to three
#' possible specifications of the infectious period: the exponential distribution, 
#' the path-specific (PS) approach of Porter and Oleson (2013),
#' or the infectious-duration dependent (IDD) formulation of Ward et al. (upcoming).
#' 
#' \code{infPeriodSpec} determines which model will be used to simulate the epidemic.
#' Model specific parameter values are entered using either \code{infExpParams}, 
#' \code{infPSParams}, or \code{infIDDParams}.
#' 
#' All models use the \code{beta} parameter vector associated with each column of the
#' matrix \code{X} to describe transmission over epidemic time. All models 
#' assume exponentially distributed time spent in the latent period with rate 
#' parameter, \code{rateE}.
#' 
#' For the exponential model \code{infPeriodSpec = 'exp'}, only one additional 
#' parameter needs to be specified in \code{infExpParams}: \code{rateI}, which is
#' the rate parameter associated with the removal probability. 
#' 
#' For the path-specific model \code{infPeriodSpec = 'PS'}, \code{infPSParams}
#' should contain three elements: \code{dist}, \code{maxInf}, and \code{psParams}.
#' \code{dist} gives the distribution used to describe the length of time spent 
#' in the infectious period Currently only the exponential (\code{"exp"}), 
#' gamma (\code{"gamma"}), and Weibull (\code{"weibull"}) distributions are supported.
#' \code{maxInf} corresponds to the maximum length of time an individual can 
#' spend in the infectious compartment, at which point the removal probability 
#' becomes 1. \code{psParams} must provide a \emph{list} of parameter values for the parameters
#' associated with the chosen distribution. For \code{dist = 'gamma'}, these are 
#' the \code{shape} and \code{rate} parameters and for \code{dist = 'weibull'}, 
#' these are the \code{shape} and \code{scale} parameters.
#' 
#' For the infectious-duration dependent model \code{infPeriodSpec = 'IDD'}, 
#' \code{infIDDParams} should contain three elements: \code{maxInf}, \code{iddFun}, 
#' and \code{iddParams}. \code{maxInf} corresponds to the total length of time 
#' each individual spends in the infectious compartment. \code{iddFun} gives
#' the IDD function used to describe the IDD curve. \code{iddParams} must provide 
#' a \emph{list} of parameter values for the parameters associated with the chosen \code{iddFun}. 
#' For example, if \code{iddFun = dgammaIDD}, these are the \code{shape} and 
#' \code{rate} parameters.
#' 
#' 
#' # specify the design matrix so there is a change point in transmission at time 50
#' X <- cbind(1, c(rep(0, 49), rep(1, tau - 49)))
#' 
#' datExp <- SEIR(S0 = 999, E0 = 0, I0 = 1, N = 1000, tau = tau,
#'                   beta = c(0.1, -2), X = X, rateE = 0.1,
#'                   infPeriodSpec = 'exp',
#'                   infExpParams = list(rateI = 0.2))
#'                   
#' # plot incidence curve
#' plot(datExp$Istar, type = 'l', main = 'Incidence', xlab = 'Epidemic Time',
#'      ylab = 'Count')
#'      
#' # simulate using IDD infectious period using the gamma PDF
#' datIDD <- SEIR(S0 = 999, E0 = 0, I0 = 1, N = 1000, tau = tau,
#'                   beta = c(0.7, -1.5), X = X, rateE = 0.1,
#'                   infPeriodSpec = 'IDD',
#'                   infIDDParams = list(maxInf = 14,
#'                                       iddFun = dgammaIDD,
#'                                       iddParams = list(shape = 4, rate = 1)))   
#'                                       
#' # plot incidence curve
#' plot(datIDD$Istar, type = 'l', main = 'Incidence', xlab = 'Epidemic Time',
#'      ylab = 'Count')
#'
#' @references Porter, Aaron T., and Oleson, Jacob J. "A path-specific SEIR model
#'  for use with general latent and infectious time distributions." \emph{Biometrics}
#'   69.1 (2013): 101-108.
#'  
#' @export
#' 
rm(list = ls())
setwd("F:/IC/project/Sar-CoV2/code")

SEIR <- function(S0, E0, I0, N, tau,
                    beta, X, rateE,
                    infPeriodSpec = c('exp', 'PS', 'IDD'),
                    infExpParams = NULL,
                    infPSParams = NULL,
                    infIDDParams = NULL) {
  
  infPeriodSpec <- match.arg(infPeriodSpec, c('exp', 'PS', 'IDD'))
  
  # check for valid initial values
  if (S0 + E0 + I0 > N) stop("N must be larger than the sum of the initial compartment values")
  
  if (S0 < 0 | E0 < 0 | I0 < 0 | N < 1 | tau < 1) {
    stop("invalid epidemic specifications (check that S0, E0, I0, N, tau >= 0)")
  }
  
  if (rateE < 0) stop("rateE must be positive")
  
  # check that beta and X are valid
  # must be matrix (later check that beta inits are same length as ncol(X))
  if(!is.matrix(X)) {
    stop('X must be a matrix')
  }
  
  # must have one row for each time point
  if (nrow(X) != tau) {
    stop('X must have rows for each time point (nrow(X) should = tau)')
  }
  
  if (ncol(X) != length(beta)) {
    stop('Value for beta must be correct length (one element for each column of X)')
  }
  
  
  if (infPeriodSpec == 'exp') {
    
    if (is.null(infExpParams)) stop('infExpParams must be specified')
    
    if (!is.list(infExpParams)) {
      stop('infExpParams must be a list')
    }
    
    if (!all(names(infExpParams) %in% c('rateI'))) {
      stop("if infPeriodSpec = 'exp', infExpParams must contain 'rateI'")
    }
    
    rateI <- infExpParams$rateI
    
    if (rateI < 0) stop("rateI must be positive")
    
    simExp(S0, E0, I0, N, tau, beta, X, rateE, rateI)
    
  } else if (infPeriodSpec == 'PS') {
    
    if (is.null(infPSParams)) stop('infPSParams must be specified')
    
    if (!is.list(infPSParams)) {
      stop('infPSParams must be a list')
    }
    
    if (!all(names(infPSParams) %in% c('dist', 'psParams', 'maxInf'))) {
      stop("if infPeriodSpec = 'PS', infPSParams must contain 'dist', 'psParams', 'maxInf'")
    }
    
    dist <- match.arg(infPSParams$dist, c('exp', 'gamma', 'weibull'))
    psParams <- infPSParams$psParams
    maxInf <- infPSParams$maxInf
    
    psParams <- psParamsCheck(psParams, dist) 
    
    if (maxInf < 1) stop('maxInf must be >= 1')
    
    simPS(S0, E0, I0, N, tau,
          beta, X, rateE, 
          dist, psParams, maxInf) 
    
  } else if (infPeriodSpec == 'IDD') {
    
    if (is.null(infIDDParams)) stop('infIDDParams must be specified')
    
    if (!is.list(infIDDParams)) {
      stop('infIDDParams must be a list')
    }
    
    if (!all(names(infIDDParams) %in% c('iddFun', 'iddParams', 'maxInf'))) {
      stop("if infPeriodSpec = 'IDD', infIDDParams must contain 'iddFun', 'iddParams', 'maxInf'")
    }
    
    iddFun <- infIDDParams$iddFun
    iddParams <- infIDDParams$iddParams
    maxInf <- infIDDParams$maxInf
    
    # if spline model, need to fix the XBasis argument and remove it from the parameters
    if (!is.character(all.equal(iddFun, splineIDD))) {
      
      XBasis <- iddParams$XBasis
      iddParams <- iddParams[-which(names(iddParams) == 'XBasis')]
      iddFun <- fixFunArgs(substitute(splineIDD(XBasis=XBasis)))
    }
    
    
    if (maxInf < 1) stop('maxInf must be >= 1')
    
    IDDCurve <- do.call(iddFun, args = list(x = 1:maxInf,
                                            params = iddParams))
    
    simIDD(S0, E0, I0, N, tau,
           beta, X, rateE, 
           IDDCurve, maxInf) 
    
  }
  

  
}





