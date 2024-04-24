# comparision of futures model vs real exchange price
source('./calibrationFunctions.R')
# Exchange futures 23-09-29
exchangeFuturesData <- read.csv("../src/tradingStartegies/data/arbitrageDataCheck/futures231229.csv",  sep = ',')
exchangeFutureClosePrice <- (as.numeric(gsub(",", "", exchangeFuturesData[, 5])))

#Exchange sport to 23-09-29
exchangeSpotData <- read.csv("../src/tradingStartegies/data/arbitrageDataCheck/btcSpot231229.csv",  sep = ',')
exchangeSpotDataClose <- (as.numeric(gsub(",", "", exchangeSpotData[, 5])))

# Rate part to 23-09-29


# smthing like KNN for missingdata in short rate

rateClose <- c(3.83
               ,3.85
               ,3.85
               ,3.85
               ,3.85
               ,3.85
               ,3.85
               ,3.85
               ,3.85
               ,3.85
               ,3.85
               ,3.85
               ,3.87
               ,3.87
               ,3.87
               ,3.88
               ,3.88
               ,3.88
               ,3.85
               ,3.87
               ,3.87
               ,3.87
               ,3.87
               ,3.87
               ,3.88
               ,3.88
               ,3.86
               ,3.86
               ,3.86
               ,3.85
               ,3.86
               ,3.86
               ,3.85
               ,3.85
               ,3.85
               ,3.85
               ,3.85
               ,3.86
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.87
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.87
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.85
               ,3.85
               ,3.86
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.86
               ,3.86
               ,3.86
               ,3.86
               ,3.86
               ,3.88
               ,3.86
               ,3.86
               ,3.85
               ,3.85
               ,3.85
               ,3.89
               ,3.89
               ,3.89
               ,3.89
               ,3.89
               ,3.88
               ,3.88
               ,3.88
               ,3.88
               ,3.62
               ,3.61
               ,3.61
               ,3.60
               ,3.60
               ,3.62
               ,3.63
               ,3.63
               ,3.62
               ,3.62
               ,3.62
               ,3.62
               ,3.61
               ,3.61
               ,3.60
               ,3.61
               ,3.61
               ,3.61
               ,3.61) / 100
repetition_factor <- ceiling(length(exchangeSpotDataClose) / length(rateClose))
enlarged_rate <- rep(rateClose, each = repetition_factor)
enlarged_rate <- head(enlarged_rate, length(exchangeSpotDataClose))
rateClose <- enlarged_rate

T <- 1
t <- (1:length(rateClose))/length(rateClose)
sigma_t <- sqrt(mleVasicek$sigma^2 * (T - t) - 2 * mleVasicek$sigma^2 * (1 - exp(-(T - t))) + mleVasicek$sigma^2 * (1 - exp(-2*(T - t))))
P_t <- exp(
  - ((mleVasicek$thetha / mleVasicek$alpha) * (T - t) +
       1/mleVasicek$alpha * (rateClose - mleVasicek$thetha / mleVasicek$alpha) * (1 - exp(-mleVasicek$alpha * (T - t))) -
       1/2 * sigma_t^2)
)

theoreticalFuturesPrice <- futuresPrice(exchangeSpotDataClose, P_t , mleVasicek$sigma, mleVasicek$alpha, 1, sigHat, corHat, t)
theorethicalForwardPrice <- exchangeSpotDataClose / P_t


data <- data.frame(t, exchangeSpotDataClose, exchangeFutureClosePrice, theoreticalFuturesPrice, theorethicalForwardPrice)
plotResult <- ggplot(data) +
  geom_line(aes(x = t, y = exchangeFutureClosePrice, color = 'Burzová cena f_t'), linetype = 'solid') +
  geom_line(aes(x = t, y = exchangeSpotDataClose, color = 'S_t'), linetype = 'solid') +
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
ggsave("../images/futuresModelResult15Min.pdf", plotResult, width = 15, height = 7)
plotResult
table <- data.frame(Close = theoreticalFuturesPrice)
write.csv(table, file = '../src/tradingStartegies/data/klam/theoreticalFutures231229.csv', row.names = FALSE)
file.exists('../src/tradingStartegies/data/klam/theoreticalFutures231229.csv')



