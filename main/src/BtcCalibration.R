library(tidyverse)
gbm_loop <- function(nsim = 100, t = 25, mu = 0, sigma = 0.1, S0 = 100, dt = 1./365) {
  gbm <- matrix(ncol = nsim, nrow = t)
  for (simu in 1:nsim) {
    gbm[1, simu] <- S0
    for (day in 2:t) {
      epsilon <- rnorm(1)
      dt = 1 / 365
      gbm[day, simu] <- gbm[(day-1), simu] * exp((mu - sigma * sigma / 2) * dt + sigma * epsilon * sqrt(dt))
    }
  }
  return(gbm)
}

nsim <- 100
t <- length(btcDailyPrice) 
mu <- mean(diff(log(btcDailyPrice)))
sigma <- sd(diff(log(btcDailyPrice)))
S0 <- btcDailyPrice[1]
gbm <- gbm_loop(nsim = nsim, t, mu, sigma, S0, 1/365)
gbm_df <- as.data.frame(gbm) %>%
  mutate(ix = 1:nrow(gbm)) %>%
  pivot_longer(-ix, names_to = 'sim', values_to = 'price')
gbm_df %>%
  ggplot(aes(x=ix, y=price, color=sim)) +
  geom_line() +
  theme(legend.position = 'none')



nsim <- 15
t <- length(btc15Min[,5])
mu <- mean(diff(log(btc15Min[,5])))
sigma <- sd(diff(log(btc15Min[,5])))
S0 <- btc15Min[1,5]
gbm <- gbm_loop(nsim = nsim, t, mu, sigma, S0, 1/(365 * 24 * 4))
gbm_df <- as.data.frame(gbm) %>%
  mutate(ix = 1:nrow(gbm)) %>%
  pivot_longer(-ix, names_to = 'sim', values_to = 'price')
gbm_df %>%
  ggplot(aes(x=ix, y=price, color=sim)) +
  geom_line() +
  theme(legend.position = 'none')


gbm_df <- as.data.frame(gbm) %>%
  mutate(ix = 1:nrow(gbm)) %>%
  pivot_longer(-ix, names_to = 'sim', values_to = 'price')

# Plot simulated GBM paths
gbm_plot <- gbm_df %>%
  ggplot(aes(x = ix, y = price, color = sim)) +
  geom_line() +
  theme(legend.position = 'none')

# Plot original btc15Min data
btc15Min_plot <- ggplot(data = btc15Min[,5], aes(x = time, y = price)) +
  geom_line(color = "black", size = 1.5) +  # Black line with larger width
  theme(legend.position = 'none')

# Combine both plots
combined_plot <- gbm_plot + btc15Min_plot
combined_plot


