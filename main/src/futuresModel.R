# comparision of futures model vs real exchange price
source('./calibrationFunctions.R')
# Exchange futures 23-09-29
exchangeFuturesData <- read.csv("../data/daily/futuresBtc230929.csv",  sep = ',')
exchangeFutureClosePrice <- rev(as.numeric(gsub(",", "", exchangeFuturesData[, 5])))

#Exchange sport to 23-09-29
exchangeSpotData <- read.csv("../data/daily/btcDaily230929.csv",  sep = ',')
exchangeSpotDataClose <- rev(as.numeric(gsub(",", "", exchangeSpotData[, 5])))

# Rate part to 23-09-29
rateDate <- read.csv("../data/daily/rate.csv", sep = ";", fileEncoding = "UCS-2LE")
rateDataFiltered <- rateDate[!is.na(rateDate[, 9]), ]
rateDataFiltered$OBS_DATE <- as.Date(rateDataFiltered$OBS_DATE, format = "%d/%m/%Y")


complete_dates <- seq(as.Date("2023-05-01"), as.Date("2023-09-30"), by = "day")
complete_df <- data.frame(OBS_DATE = complete_dates)
merged_df <- merge(complete_df, rateDataFiltered, by = "OBS_DATE", all.x = TRUE)

# smthing like KNN for missingdata in short rate
for (i in 1:nrow(merged_df)) {
  # Check if there is a corresponding value in rateDataFiltered
  if (!is.na(merged_df[i,5])) {
    next
  }
  currentDate <- merged_df[i,1]
  if(currentDate < rateDataFiltered[1,1] || currentDate >  rateDataFiltered[length(rateDataFiltered[,1]),1]) {
    next
  }
  previousDate <- NULL
  nextDate <- NULL
  if(i == 1) {
    nextDate <- merged_df[i + 1, 1]
    merged_df[i, 5] <- rateDataFiltered[rateDataFiltered[, 1] == nextDate, 5]
    next
  }  
  if(i == nrow(merged_df)) {
    previousDate <- merged_df[i - 1, 1]
    merged_df[i, 5] <- rateDataFiltered[rateDataFiltered[, 1] == previousDate, 5]
    next
  }
  nextDate <- merged_df[i + 1, 1]
  previousDate <- merged_df[i - 1, 1]
  merged_df[i, 5] <- mean(c(rateDataFiltered[rateDataFiltered[, 1] == nextDate, 5], rateDataFiltered[rateDataFiltered[, 1] == previousDate, 5]))
  
}

rateClose <- merged_df[,5] / 100

# Now create theoretical formula for futures for given period
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
ggsave("../images/futuresModelResult.pdf", plotResult, width = 15, height = 7)
 plotResult



