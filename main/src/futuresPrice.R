# Najprv je potrebne spustit calibrationScript.R ...
# calculate current price of futures contract
source('./calibrationFunctions.R')
S_now <- 43638.3
# time frame maturity = 1 (predtavuje napr kontrakt na 90 dni)
T <- 1  
daysUntilEnd <- 19
# kde sa aktualne nachadzame
t <- ((365 - daysUntilEnd) /365)
# najnovsi urok v aktualnom mesiaci s ktorom budeme pracovat
lastR_t <- r_t[length(r_t)]
# najnovsia sigmat_T
lastSigma_t <- sigma_t[length(sigma_t)]
# vytvori sa aktualna nominalna 'cena' dlhopisu, ktoreho maturita je v case T a bol zapocaty v case 0/90
P_now <- exp(
  - ((mleVasicek$thetha / mleVasicek$alpha) * (T - t) +
       1/mleVasicek$alpha * (lastR_t - mleVasicek$thetha / mleVasicek$alpha) * (1 - exp(-mleVasicek$alpha * (T - t))) -
       1/2 * lastSigma_t^2)
)
# vytvori sa aktualna cena futures kontraktu
futuresPrice(S_now, P_now , mleVasicek$sigma, mleVasicek$alpha, 1, sigHat, corHat, t)
# 43960 burza vs 43725.85 model


# podme si pozriet celkovy vyvoj predosleho futures kontraktu spolu s porovnanim vyvoja trhovej ceny za danych 45 dni existencie kontraktu

exchangeFuturesPrice <- read.csv("../data/daily/bitcoinFutures.csv",  sep = ',')
# urokove data ziskanne na dennej baze
rate <- read.csv("../data/daily/rate.csv", sep = ";", fileEncoding = "UCS-2LE")
btcPrice <- read.csv("../data/daily/btcDaily.csv", sep = ",")
rateValues <- rate[, 5]
exchangeFutureValues <- rev(as.numeric(gsub(",", "", exchangeFuturesPrice[, 2])))
btcValues <- btcPrice[, 5]
daysBack <- min(length(btcValues), length(exchangeFutureValues), length(rateValues))  - 1
r_t <- rateValues[(length(rateValues) - daysBack): length(rateValues)] / 100
S_t <- btcValues[(length(btcValues) - daysBack): length(btcValues)]
f_t <- exchangeFutureValues[(length(exchangeFutureValues) - daysBack): length(exchangeFutureValues)]
T <- 1
t <- rev((365 - ((45 -  daysBack ): 45))/365)
sigma_t <- sqrt(mleVasicek$sigma^2 * (T - t) - 2 * mleVasicek$sigma^2 * (1 - exp(-(T - t))) + mleVasicek$sigma^2 * (1 - exp(-2*(T - t))))
P_t <- exp(
  - ((mleVasicek$thetha / mleVasicek$alpha) * (T - t) +
       1/mleVasicek$alpha * (r_t - mleVasicek$thetha / mleVasicek$alpha) * (1 - exp(-mleVasicek$alpha * (T - t))) -
       1/2 * sigma_t^2)
)
theoreticalFuturesPrice <- futuresPrice(S_t, P_t , mleVasicek$sigma, mleVasicek$alpha, 1, sigHat, corHat, t)
theorethicalForwardPrice <- S_t / P_t


# Porovnanie cien
# Plot using ggplot2
data <- data.frame(t, S_t, exchangeFutureValues, theoreticalFuturesPrice, theorethicalForwardPrice)
ggplot(data) +
  geom_line(aes(x = t, y = exchangeFutureValues, color = 'Burzová cena f_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = S_t, color = 'S_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = theorethicalForwardPrice, color = 'Teoretická cena F_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = theoreticalFuturesPrice, color = 'Teoretická cena f_t'), linetype = 'solid') +
  labs(
    title = "Porovnanie cien",
    x = "t",
    y = "cena",
    caption = "Porovnanie vývoja cien"
  ) +
  scale_color_manual(
    values = c('Burzová cena f_t' = 'green', 'S_t' = 'red', 'Teoretická cena f_t' = 'pink', 'Teoretická cena F_t' = 'blue'),
    labels = c('Burzová cena f_t', 'S_t', 'Teoretická cena f_t', 'Teoretická cena F_t')
  )

# Ako sa meni miera futures_cena_t / S_t v zavislosti od casu
pd <- theoreticalFuturesPrice / S_t
data <- data.frame(t, pd)
ggplot(data) +
  geom_line(aes(x = t, y = pd), linetype = 'dotted')  +
  labs(
    x = "t",
    y = "pomer f_t / S_t",
    caption = "L",
    title = "Porovnanie f_t / S_t"
  )


# Zmenme r_t aby malo aj zaporne hodnoty
set.seed(221)
randomSigns <- sample(c(-1, 1), length(r_t), replace = TRUE)
negativeR_t <- r_t * randomSigns
P_t <- exp(
  - ((mleVasicekNegative$thetha / mleVasicekNegative$alpha) * (T - t) +
       1/mleVasicekNegative$alpha * (negativeR_t - mleVasicekNegative$thetha / mleVasicekNegative$alpha) * (1 - exp(-mleVasicekNegative$alpha * (T - t))) -
       1/2 * sigma_t^2)
)
theoreticalFuturesPrice <- futuresPrice(S_t, P_t , mleVasicekNegative$sigma, mleVasicekNegative$alpha, 1, sigHat, corHat, t)
theorethicalForwardPrice <- S_t / P_t
# Porovnanie cien
# Plot using ggplot2
data <- data.frame(t, S_t, exchangeFutureValues, theoreticalFuturesPrice, theorethicalForwardPrice)
ggplot(data) +
  geom_line(aes(x = t, y = S_t, color = 'Cena S_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = exchangeFutureValues, color = 'Burzová cena f_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = theoreticalFuturesPrice, color = 'Teoretická cena f_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = theorethicalForwardPrice, color = 'Teoretická cena F_t'), linetype = 'solid') +
  labs(
    title = "Porovnanie cien",
    x = "t",
    y = "cena",
    caption = "Porovnanie vývoja cien"
  ) +
  scale_color_manual(
    values = c('Cena S_t' = 'green', 'Burzová cena f_t' = 'red', 'Teoretická cena f_t' = 'pink', 'Teoretická cena F_t' = 'blue'),
    labels = c('Cena S_t', 'Burzová cena f_t', 'Teoretická cena f_t', 'Teoretická cena F_t', 'Teoretická cena F_t')
  )

# V pripade konstanta * negativnyUrok
constNegativeR_t <- negativeR_t * 10
P_t <- exp(
  - ((mleVasicekConstNegative$thetha / mleVasicekConstNegative$alpha) * (T - t) +
       1/mleVasicekConstNegative$alpha * (constNegativeR_t - mleVasicekConstNegative$thetha / mleVasicekConstNegative$alpha) * (1 - exp(-mleVasicekConstNegative$alpha * (T - t))) -
       1/2 * sigma_t^2)
)
theoreticalFuturesPrice <- futuresPrice(S_t, P_t , mleVasicekConstNegative$sigma, mleVasicekConstNegative$alpha, 1, sigHat, corHat, t)
theorethicalForwardPrice <- S_t / P_t
# Porovnanie cien
# Plot using ggplot2
data <- data.frame(t, S_t, exchangeFutureValues, theoreticalFuturesPrice, theorethicalForwardPrice)
ggplot(data) +
  geom_line(aes(x = t, y = S_t, color = 'Cena S_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = exchangeFutureValues, color = 'Burzová cena f_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = theoreticalFuturesPrice, color = 'Teoretická cena f_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = theorethicalForwardPrice, color = 'Teoretická cena F_t'), linetype = 'solid') +
  labs(
    title = "Porovnanie cien",
    x = "t",
    y = "cena",
    caption = "Porovnanie vývoja cien"
  ) +
  scale_color_manual(
    values = c('Cena S_t' = 'green', 'Burzová cena f_t' = 'red', 'Teoretická cena f_t' = 'pink', 'Teoretická cena F_t' = 'blue'),
    labels = c('Cena S_t', 'Burzová cena f_t', 'Teoretická cena f_t', 'Teoretická cena F_t', 'Teoretická cena F_t')
  )


# sledujme zmenu vzajomnych poloh futuresu a forwardu od vstupnych hodnot corHatTemp
corHatTemp <- 1
corHatTemp <- -1
corHatTemp <- 0
const <- 100
corHatTemp <- 1 * const
P_t <- exp(
  - ((mleVasicek$thetha / mleVasicek$alpha) * (T - t) +
       1/mleVasicek$alpha * (r_t - mleVasicek$thetha / mleVasicek$alpha) * (1 - exp(-mleVasicek$alpha * (T - t))) -
       1/2 * sigma_t^2)
)
theoreticalFuturesPrice <- futuresPrice(S_t, P_t , mleVasicek$sigma, mleVasicek$alpha, 1, sigHat, corHatTemp, t)
theorethicalForwardPrice <- S_t / P_t
eps <- 10^(-6)
theoreticalFuturesPrice - theorethicalForwardPrice < eps
abs(theoreticalFuturesPrice - theorethicalForwardPrice) < eps
theoreticalFuturesPrice - theorethicalForwardPrice

# zmena volatility sigma_r
mleVasicek$sigma <- 3
P_t <- exp(
  - ((mleVasicek$thetha / mleVasicek$alpha) * (T - t) +
       1/mleVasicek$alpha * (r_t - mleVasicek$thetha / mleVasicek$alpha) * (1 - exp(-mleVasicek$alpha * (T - t))) -
       1/2 * sigma_t^2)
)
theoreticalFuturesPrice <- futuresPrice(S_t, P_t , mleVasicek$sigma, mleVasicek$alpha, 1, sigHat, corHat, t)
theorethicalForwardPrice <- S_t / P_t
ggplot(data) +
  geom_line(aes(x = t, y = exchangeFutureValues, color = 'Burzová cena f_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = S_t, color = 'S_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = theorethicalForwardPrice, color = 'Teoretická cena F_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = theoreticalFuturesPrice, color = 'Teoretická cena f_t'), linetype = 'solid') +
  labs(
    title = "Porovnanie cien",
    x = "t",
    y = "cena",
    caption = "Porovnanie vývoja cien"
  ) +
  scale_color_manual(
    values = c('Burzová cena f_t' = 'green', 'S_t' = 'red', 'Teoretická cena f_t' = 'pink', 'Teoretická cena F_t' = 'blue'),
    labels = c('Burzová cena f_t', 'S_t', 'Teoretická cena f_t', 'Teoretická cena F_t')
  )

