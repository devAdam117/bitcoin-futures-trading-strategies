source('./calibrationFunctions.R')
rateData <- read.csv("../data/monthly/DP_LIVE_05112023104956950.csv", header = TRUE, sep = ',')
btc15Min <- read.csv('../src/tradingStartegies/data/15m2024_02_04_to_2024_02_10/BTC.csv', header = TRUE, sep = ',')
# btcData <- read.csv("/Users/adammartinka/Downloads/BTC-USD.csv", header = TRUE, sep = ',')
btcData <- read.csv("../data/daily/data.csv",  sep = ';')[-c(1, 2),]
btcDailyData <- read.csv("../data/daily/btcDaily.csv",  sep = ',', header = TRUE)
btcDailyPrice <- rev(as.numeric(gsub(",", "", btcDailyData[, 2])))
numeric_vector <- as.numeric(gsub(",", "", btcData[, 2]))
library(stats)
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
negativeR_tForCalibration <- randomSigns * r_tForCalibration
mleVasicekNegative <- getMLEVasicek(negativeR_tForCalibration, 1/12)
mleVasicekConstNegative <- getMLEVasicek(30 * negativeR_tForCalibration, 1/12)
# T je pocet rokov
T <- length(r_t)/12
# t je pohyb mesiacov az do posledneho T
t <- (1: length(r_t))/12
# ide sa urcovat bezkuponovy dlhopis ktory je nastaveny v case 0 a jeho maturita je v T (... vyuziva vsak vsetky parametre z realneho sveta, zostal tu iba z hist. hladiska ...)
sigma_t <- sqrt(mleVasicek$sigma^2 * (T - t) - 2 * mleVasicek$sigma^2 * (1 - exp(-(T - t))) + mleVasicek$sigma^2 * (1 - exp(-2*(T - t))))
P_t <- exp(
  - ((mleVasicek$thetha / mleVasicek$alpha) * (T - t) +
    1/mleVasicek$alpha * (r_t - mleVasicek$thetha / mleVasicek$alpha) * (1 - exp(-mleVasicek$alpha * (T - t))) -
    1/2 * sigma_t^2)
)

# implicitny vypocet thetha_RN, ktory sa ma defaultne pouzivat v ocenovani P_t, ked mame k dispozici nakalaibrovane parametre MLE z Vasicka + r(30)
# T je pocet rokov
T <- 1/12
# t je pohyb mesiacov az do posledneho T
t <- 0
r_current <- 0.0388
# ide sa urcovat bezkuponovy dlhopis ktory je nastaveny v case 0 a jeho maturita je v T
sigma_t <- sqrt(mleVasicek$sigma^2 * (T - t) - 2 * mleVasicek$sigma^2 * (1 - exp(-(T - t))) + mleVasicek$sigma^2 * (1 - exp(-2*(T - t))))
# 30 days bond 
P_30 <- exp(-r_current * 1/12)
# Implicitny vypocet
theta_RN <- implicit_theta_RN(P_30, mleVasicek$alpha, sigma_t, r_current, T, t)
print(paste("Implicitly calculated theta_RN:", theta_RN))

# A teraz vypocet pomocou minimalizacie sumy stvorcov
# LSE + optimization to find thetha_{RN}
options(digits = 20)
bondPricesLeft <- exp(-r_tForCalibration * 1/12)
result <- optimize(f = objWrapper, interval = c(0,2))
theta_RN <- result$minimum
# Plot pre vyslednu zvolenu hodnotu
theta_values <- seq(0, 0.05, length.out = 3000)  
obj_values <- sapply(theta_values, objWrapper)
plot(theta_values, obj_values, type = "l", xlab = "thetha_{RN}", ylab = "Suma štvorcov")
abline(v = theta_RN, col = "red")  
print(paste("theta_RN after using min(LSE)_thetha:", theta_RN))
options(digits = 6)


# T je pocet rokov
T <- length(r_t)/12
# t je pohyb mesiacov az do posledneho T
t <- (1: length(r_t))/12
# ide sa urcovat bezkuponovy dlhopis ktory je nastaveny v case 0 a jeho maturita je v T (... vyuziva vsak vsetky parametre z realneho sveta, zostal tu iba z hist. hladiska ...)
sigma_t <- sqrt(mleVasicek$sigma^2 * (T - t) - 2 * mleVasicek$sigma^2 * (1 - exp(-(T - t))) + mleVasicek$sigma^2 * (1 - exp(-2*(T - t))))
P_t <- exp(
  - ((theta_RN / mleVasicek$alpha) * (T - t) +
       1/mleVasicek$alpha * (r_t - theta_RN / mleVasicek$alpha) * (1 - exp(-mleVasicek$alpha * (T - t))) -
       1/2 * sigma_t^2)
)



## Grafy dlhopis vs urok
pdf("plot.pdf") 
df <- data.frame(
  Time = t + 2011,
  P_T = P_t,
  r_t = log(r_t + 1)
)


p <- ggplot(df, aes(x = Time)) +
  geom_line(aes(y = log(P_t), color = "P(t,T)")) +
  geom_line(aes(y = r_t , color = "r(t)")) +
  scale_color_manual(values = c("P(t,T)" = "red", "r(t)" = "blue")) +
  labs(title = "Dynamika P(t,T) v závislosti od r(t)",
       x = "rok") +
  theme_minimal() + 
  scale_y_continuous("log(r(t) + 1)", sec.axis = sec_axis(~ (. + 1), name = "P(t,T)"))
# P_t + r_t
p + theme( axis.line.y.right = element_line(color = "red")) + theme(axis.line.y.left = element_line(color = "blue"))
dev.off()
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

# Test normality pre log vynosy btc
shapiro.test(logReturnsBTC)

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


# Daily Interval
nsim <-30
t <- length(btcDailyPrice)
mu <- (1 + mean(diff(log(btcDailyPrice))))^365 - 1
sigma <- sd(diff(log(btcDailyPrice))) * sqrt(365)
S0 <- btcDailyPrice[1]
gbm <- gbm_loop(nsim = nsim, t, mu, sigma, S0, 1/365)
gbm_df <- as.data.frame(gbm) %>%
  mutate(ix = 1:nrow(gbm)) %>%
  pivot_longer(-ix, names_to = 'sim', values_to = 'price')

# plot the gbm_df data
p <- ggplot(gbm_df, aes(x = ix, y = price, color = sim)) +
  geom_line(size = 0.25) +  
  theme(legend.position = 'none') +
  xlab("t") +  
  ylab("S(t)") +  
  ylim(0, 500000)  

p <- p + geom_line(data = data.frame(Date = seq_along(btcDailyPrice), Price = btcDailyPrice),
              aes(x = Date, y = Price), color = "black")
p

library(moments)
log_ret_kurtosis <- kurtosis(diff(log(btcDailyPrice )))
log_ret_skewness <- skewness(diff(log(btcDailyPrice)))
kurtosis(diff(log(gbm[,1])))
skewness_values <- numeric()
kurtosis_values <- numeric()

for (i in 1:ncol(gbm)) {
  skewness_values <- c(skewness_values, skewness(diff(log((gbm[, i])))))
  kurtosis_values <- c(kurtosis_values, kurtosis(diff(log((gbm[, i] )))))
}

cat("Real skewness of log returns:",log_ret_skewness , "vs generated avg. skewness: ", mean(skewness_values), "\n\n")
cat("Real kurtosis of log returns:",log_ret_kurtosis , "vs generated avg. kurtosis: ", mean(kurtosis_values), "\n\n")

par(mfrow = c(1, 2))  
hist(skewness_values, main = "Histogram of Skewness Values", xlab = "Skewness", ylab = "Frequency")

hist(kurtosis_values, main = "Histogram of Kurtosis Values", xlab = "Kurtosis", ylab = "Frequency")


ggsave("calibrationBtc.pdf", plot = p, device = "pdf")


# 15min interval
nsim <- 300
t <- 72000
dt <- 1 / (365 * 24 * 4)  
mu <- ((1 + mean(diff(log(btcDailyPrice))))^365 - 1)
sigma <- (sd(diff(log(btcDailyPrice))) * sqrt(365))
S0 <- btcDailyPrice[1]
#gbm <- gbm_loop(nsim = nsim, t = t, mu = mu, sigma = sigma, S0 = S0, dt = dt)

# plot the gbm_df data
# p <- ggplot(gbm, aes(x = ix, y = price, color = sim)) +
#  geom_line(size = 0.25) +  
#  theme(legend.position = 'none') +
#  xlab("t") +  
#  ylab("S(t)") +  
#  ylim(0, 50000)  


# p






gbm_df <- as.data.frame(gbm) %>%
  mutate(ix = 1:nrow(gbm)) %>%
  pivot_longer(-ix, names_to = 'sim', values_to = 'price')




savePathAsCSV <- function(path, index) {
  data <- data.frame(
    open_time = seq(0, length(path) - 1) * 15 * 60,  # Convert ticks to seconds
    Open = 0,
    High = 0,
    Low = 0,
    Close = path
  )
  filename <- paste0("./tradingStartegies/data/15mBtcMonteCarlo/MonteCarloBtc", index, ".csv")
  write.csv(data, filename, row.names = FALSE)
}

#for (i in 1:ncol(gbm)) {
#  savePathAsCSV(gbm[, i], i)
#}
ggsave("calibration15MinBtc.pdf", plot = p, device = "pdf")



# cor betweeen btc and short rate

dailyRate <- read.csv("../data/daily/rate.csv", sep=";", fileEncoding="UTF-16LE", stringsAsFactors=FALSE)
btcDailyData <- read.csv("../data/daily/btcDaily.csv",  sep = ',', header = TRUE)
dailyRate <- dailyRate[!is.na(dailyRate[,9]),][,c(1,9)]
btcDailyData <- btcDailyData[, c(1, 2)]


btcDailyData$Date <- as.Date(btcDailyData$Date, format = "%d/%m/%Y")
dailyRate$OBS_DATE <- as.Date(dailyRate$OBS_DATE, format = "%d/%m/%Y")
mergedData <- merge(btcDailyData, dailyRate, by.x = "Date", by.y = "OBS_DATE")
btcPrice <- as.numeric(gsub(",", "", mergedData[, 2]))
diffBtc <- diff(log(btcPrice))
#diffBtc <- diff(btcPrice)  / btcPrice[-length(btcPrice)]

rateValues <- mergedData[,3]
t <- (1: length(mergedData[,3])) / length(mergedData[, 3])
dt <- diff(t)
diffRate <- diff(rateValues)  + mleVasicek$alpha * rateValues[-length(rateValues)] * dt
cor(diffRate, diffBtc)

cor.test(diffRate, diffBtc, alternative="two.sided", method = 'spearman')


