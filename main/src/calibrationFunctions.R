library(tidyverse)
# vypocita implikovany volatilitu podla dannej call opcie
blackScholesCall <- function(S, K, r, T, sigma) {
  d1 <- (log(S / K) + (r + (sigma^2) / 2) * T) / (sigma * sqrt(T))
  d2 <- d1 - sigma * sqrt(T)
  N_d1 <- pnorm(d1)
  N_d2 <- pnorm(d2)
  call_price <- S * N_d1 - K * exp(-r * T) * N_d2
  return(call_price)
}

blackScholesPut <- function(S, K, r, T, sigma){
    d1 <- (log(S/K) + (r + sigma^2/2)*T) / (sigma*sqrt(T))
    d2 <- d1 - sigma*sqrt(T)
    
    value <-  (K*exp(-r*T)*pnorm(-d2) - S*pnorm(-d1))
    return(value)
}

# podla cvick z financych derivatov / diplomovky tatiany.
getMLEVasicek <- function(r,dt=1/12) { 
  n <- length(r) - 1
  alpha_hat <- (n*sum(r[-1]*r[-(n + 1)]) - sum(r[-1])*sum(r[-(n + 1)]))/(n*sum((r[-(n + 1)])^2) - (sum(r[-(n + 1)]))^2)
  beta_hat <- sum(r[-1] - alpha_hat*r[-(n + 1)])/(n*(1 - alpha_hat))
  v2_hat <- 1/n*(sum((r[-1] - alpha_hat*r[-(n + 1)] - beta_hat*(1 - alpha_hat))^2))
  kappa_hat <- -log(alpha_hat)/dt
  theta_hat <- beta_hat
  sigma_hat <- (v2_hat*2*kappa_hat)/(1-exp(-2*kappa_hat*dt))
  alphaVasicek <- kappa_hat
  thethaVasicek <- (kappa_hat * theta_hat + sigma_hat * 1) / kappa_hat
  sigmaVasicek <- sigma_hat
  return(list(alpha=alphaVasicek, thetha=thethaVasicek, sigma=sigmaVasicek))
}
# ocenovacia formulka pre futures kontrakt 
futuresPrice <- function(S, P, sigmaR, alpha, T, sigmaS, rho, t) {
  term1 <- (1 - exp(-2 * alpha * (T - t))) / (2 * alpha) - 2 * (1 - exp(-alpha * (T - t))) / alpha + (T - t)
  term2 <- (sigmaR^2 / alpha^2) * term1
  term3 <- ((sigmaR * sigmaS * rho) / alpha) * ((1 - exp(-alpha * (T - t))) / alpha + t - T)
  futures_price <- S / P * exp(term2 - term3)
  return(futures_price)
}

# zmeny nahodne znamienka daneho vektora ( napr pre urok...)
random_sign <- function(numbers) {
  signs <- sample(c(1, -1), length(numbers), replace = TRUE)
  result <- signs * numbers
  return(result)
} 

# vrati optimalne mle hodnoty pre dany GBM
getParametersBitcoinGBM <- function(S, dt=1) {
  returns <- diff(log(S))
  m <- mean(returns)
  s <- sd(returns)
  return (list(mu=m/dt, sigma = sqrt(s / dt)))
}




gbm_loop <- function(nsim = 100, t = 25, mu = 0, sigma = 0.1, S0 = 100, dt = 1./365) {
  gbm <- matrix(ncol = nsim, nrow = t)
  for (simu in 1:nsim) {
    gbm[1, simu] <- S0
    for (day in 2:t) {
      epsilon <- rnorm(1)
      gbm[day, simu] <- gbm[(day-1), simu] * exp((mu - sigma * sigma / 2) * dt + sigma * epsilon * sqrt(dt))
    }
  }
  return(gbm)
}


bondPrice <- function(theta_RN, alpha, sigma_t, r_current, T, t) {
  exp(
    - ((theta_RN / alpha) * (T - t) +
         1/alpha * (r_current - theta_RN / alpha) * (1 - exp(-alpha * (T - t))) -
         1/2 * sigma_t^2)
  )
}

implicit_theta_RN <- function(P_market, alpha, sigma_t, r_current, T, t) {
  theta_RN_values <- seq(0.001, 2, by = 0.001)  
  for (theta_RN in theta_RN_values) {
    diff <- abs(P_market - bondPrice(theta_RN, alpha, sigma_t, r_current, T, t))
    if ((diff) < 0.000001) {
      return(theta_RN)
    }
  }
  return(NA)  
}

obj <- function(bondPricesLeft, bondPricesRight) {
  return(sum( (bondPricesLeft - bondPricesRight)^2  ))
}

objWrapper <- function(thetha) {
  # reads from context ...
  bondPricesRight <- bondPrice(thetha, mleVasicek$alpha, sigma_t, r_tForCalibration, T, t)
  return(obj(bondPricesLeft, bondPricesRight))
}

