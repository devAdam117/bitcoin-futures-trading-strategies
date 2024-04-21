source('./calibrationFunctions.R')
rateData <- read.csv("../data/monthly/DP_LIVE_05112023104956950.csv", header = TRUE, sep = ',')
btc15Min <- read.csv('../src/tradingStartegies/data/15m2024_02_04_to_2024_02_10/BTC.csv', header = TRUE, sep = ',')
# btcData <- read.csv("/Users/adammartinka/Downloads/BTC-USD.csv", header = TRUE, sep = ',')
btcData <- read.csv("../data/daily/data.csv",  sep = ';')[-c(1, 2),]
btcDailyData <- read.csv("../data/daily/btcDaily.csv",  sep = ',', header = TRUE)
btcDailyPrice <- rev(as.numeric(gsub(",", "", btcDailyData[, 2])))
numeric_vector <- as.numeric(gsub(",", "", btcData[, 2]))
# ak nie je package nainstalovany
# install.packages(ggplot2)
library(ggplot2)
# ak nie je package nainstalovany
# install.packages(plyr)
library(plyr)
# short rate
r_t <- rateData[, 7]/100
# pri kalibracii vasicka z historickych dat vychadzali mne aj kolegyni nevhodne parametre, napr parameter, ktory urcuje rychlost spadu
# k mean reversion bol zaporny, vraj to sposobovali nove data, takze pri kallibracii sa ane data odstranili.
r_tForCalibration <- r_t[-c(122:151)]
btcLength <- length(btcData[, 1])
# cena btc
btcPrice <-rev(numeric_vector)
# load kalibracnych funkcii
source('calibrationFunctions.R')
# mle odhady parametrov vasicka
mleVasicek <- getMLEVasicek(r_tForCalibration, 1/12)
set.seed(221)
randomSigns <- sample(c(-1, 1), length(r_tForCalibration), replace = TRUE)
negativeR_tForCalibration <- randomSigns* r_tForCalibration
mleVasicekNegative <- getMLEVasicek(negativeR_tForCalibration, 1/12)
mleVasicekConstNegative <- getMLEVasicek(30 * negativeR_tForCalibration, 1/12)
# T je pocet rokov
T <- length(r_t)/12
# t je pohyb mesiacov az do posledneho T
t <- (1: length(r_t))/12
# ide sa urcovat bezkuponovy dlhopis ktory je nastaveny v case 0 a jeho maturita je v T
sigma_t <- sqrt(mleVasicek$sigma^2 * (T - t) - 2 * mleVasicek$sigma^2 * (1 - exp(-(T - t))) + mleVasicek$sigma^2 * (1 - exp(-2*(T - t))))
P_t <- exp(
  - ((mleVasicek$thetha / mleVasicek$alpha) * (T - t) +
    1/mleVasicek$alpha * (r_t - mleVasicek$thetha / mleVasicek$alpha) * (1 - exp(-mleVasicek$alpha * (T - t))) -
    1/2 * sigma_t^2)
)


## Grafy dlhopis vs urok
df <- data.frame(
  Time = t + 2011,
  P_T = log(P_t),
  r_t = log(r_t + 1)
)


p <- ggplot(df, aes(x = Time)) +
  geom_line(aes(y = log(P_t), color = "log(P(t,T))")) +
  geom_line(aes(y = r_t , color = "r(t)")) +
  scale_color_manual(values = c("log(P(t,T))" = "red", "r(t)" = "blue")) +
  labs(title = "Dynamika log(P(t,T)) v závislosti od r(t)",
       x = "rok") +
  theme_minimal() + 
  scale_y_continuous("r(t)", sec.axis = sec_axis(~ (. + 1), name = "P(t,T)"))
# P_t + r_t
p + theme( axis.line.y.right = element_line(color = "red")) + theme(axis.line.y.left = element_line(color = "blue"))

## Grafy pre dlhopis vs bitcoin
PForBtc_t <- P_t

dfBtc <- data.frame(
  Time = t + 2011,
  BTC = btcPrice
)


dfPt <- data.frame(
  Time = t + 2011,
  P_T = PForBtc_t
)


btcPlot <- ggplot(dfBtc, aes(x = Time)) +
  geom_line(color = "blue", size = 0.3, y = btcPrice) +
  labs(title = "Cena Bitcoinu",
       x = "rok",
       y = "S(t)",
       col = "Blue") +
  scale_y_continuous(limits = c(300, 60000)) +
  theme_minimal()

ptPlot <- ggplot(dfPt, aes(x = Time)) +
  geom_line(color = "red", size = 0.3, y = PForBtc_t) +
  labs(title = "Diskontný dlhopis",
       x = "rok",
       y = "P(t,T)",
       col = "Red") +
  scale_y_continuous(limits = c(0.90, 1.01)) +
  theme_minimal()
# ak nie je package nainstalovany
# install.packages(gridExtra)
library(gridExtra)
grid.arrange(ptPlot, btcPlot)


# Historicka korelacia
logReturnsBTC <- diff(log(btcPrice))
logReturnsBond <- diff(log(P_t))
corHat <- cor(logReturnsBTC, logReturnsBond)

cor.test(logReturnsBTC, logReturnsBond, alternative="two.sided", method = 'spearman')

# Implikovana volatility v dany den (10.12.2023)
sigHat <- 0.0
maxError <- 1
exchangePrice <- 1370
currentPrice <- 43638.3
strikePrice <- 43000
T <- 19/365
it <- 0 
maxIter <- 1000000
theoreticalPrice <- blackScholesCall(currentPrice, strikePrice, 0.03, T, sigHat)

# brute force method .. not binary for time savement..
while(abs(exchangePrice - theoreticalPrice) > maxError && it < maxIter){
  it <- it + 1
  sigHat <- sigHat + 0.00001
  theoreticalPrice <- blackScholesCall(currentPrice, strikePrice, 0.03, T, sigHat)
}
sigHat

# Check optimal parameters for GBM of bitcoin

# Daily Interval



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

# 15 Min Interval

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




