# Skriptik na vypocet volatility smile pre bid a ask zo dna 10.12.2023
source('./calibrationFunctions.R')
maxError <- 1
T <- 1 - (365 - 19)/365
# on exchange
strikePrices <- c(15, 20, 22, 23, 24, 25, 26, 27, 28, 29, 30: 45, 48, 50, 55, 60, 80) * 1000
# on exchange ( refference onin images/options*)
bidPricesCall <- c(21745, 20665, 18930, 18060, 17195, 16325, 15460, 14590, 13725, 12860, 11990, 11125, 10260, 9395, 8530, 7665, 6805, 5945, 6085, 5190, 4335, 3570, 2840, 1370, 1750, 1375, 605, 365, 140, 65, 30)
askPricesCall <- c(34795, 31495, 23000, 28590, 27225, 20000, 24490, 18000, 17000, 20390, 15000, 17660, 16295, 14390, 13575, 10000, 9615, 9210, 8000, 7795, 5500, 5375, 4280, 2350, 2200, 1430, 850, 525, 195, 190, 45)
bidPricesPut <- c(0, 5, 5, 10, 15, 20, 20, 25, 40, 55, 55, 45, 60, 70, 85, 85, 145, 195, 260, 360, 505, 720, 1010, 1225, 1855, 2480, 4650, 6375, 9270, 13595, 30930 )
askPricesPut <- c(10, 20, 30, 30, 35, 35, 40, 45, 55, 65, 65, 75, 90, 105, 120, 145, 185, 205, 270, 370, 535, 750, 1045, 1765, 2800, 3705, 6985, 9575, 27170, 31110, 48905)
# on exchange
currentPrice <- 43638.3
volatilitySmileBidCall <- c()
volatilitySmileAskCall <- c()
maxIter <- 1000000
for (i in 1:length(strikePrices)) {
  print(i)
  it <- 0
  sigHat <- 0.0001
  currentStrikePrice <- strikePrices[i]
  currentBidPrice <- bidPricesCall[i]
  theoreticalPrice <- blackScholesCall(currentPrice, currentStrikePrice, 0.03, T, sigHat)
  while(abs(currentBidPrice - theoreticalPrice) > maxError && it < maxIter){
    it <- it + 1
    sigHat <- sigHat + 0.00001
    theoreticalPrice <- blackScholesCall(currentPrice, currentStrikePrice, 0.03, T, sigHat)
  }
  if(it == maxIter )  sigHat <- 0

  volatilitySmileBidCall <- c(volatilitySmileBidCall, sigHat)
}

for (i in 1:length(strikePrices)) {
  print(i)
  it <- 0
  sigHat <- 0.0
  currentStrikePrice <- strikePrices[i]
  currentAskPrice <- askPricesCall[i]
  theoreticalPrice <- blackScholesCall(currentPrice, currentStrikePrice, 0.03, T, sigHat)
  while(abs(currentAskPrice - theoreticalPrice) > maxError && it < maxIter){
    it <- it + 1
    sigHat <- sigHat + 0.00001
    theoreticalPrice <- blackScholesCall(currentPrice, currentStrikePrice, 0.03, T, sigHat)
  }
  if(it == maxIter ) sigHat <- 0
  volatilitySmileAskCall <- c(volatilitySmileAskCall, sigHat)
}

volatilitySmileBidPut <- c()
volatilitySmileAskPut <- c()
maxIter <- 1000000
for (i in 1:length(strikePrices)) {
  print(i)
  it <- 0
  sigHat <- 0.0001
  currentStrikePrice <- strikePrices[i]
  currentBidPrice <- bidPricesPut[i]
  theoreticalPrice <- blackScholesPut(currentPrice, currentStrikePrice, 0.03, T, sigHat)
  while(abs(currentBidPrice - theoreticalPrice) > maxError && it < maxIter){
    it <- it + 1
    sigHat <- sigHat + 0.00001
    theoreticalPrice <- blackScholesPut(currentPrice, currentStrikePrice, 0.03, T, sigHat)
  }
  if(it == maxIter )  sigHat <- 0
  
  volatilitySmileBidPut <- c(volatilitySmileBidPut, sigHat)
}

for (i in 1:length(strikePrices)) {
  print(i)
  it <- 0
  sigHat <- 0.0
  currentStrikePrice <- strikePrices[i]
  currentAskPrice <- askPricesPut[i]
  theoreticalPrice <- blackScholesCall(currentPrice, currentStrikePrice, 0.03, T, sigHat)
  while(abs(currentAskPrice - theoreticalPrice) > maxError && it < maxIter){
    it <- it + 1
    sigHat <- sigHat + 0.00001
    theoreticalPrice <- blackScholesPut(currentPrice, currentStrikePrice, 0.03, T, sigHat)
  }
  if(it == maxIter ) sigHat <- 0
  volatilitySmileAskPut <- c(volatilitySmileAskPut, sigHat)
}

zipMinNonZero <- function(vector1, vector2) {
  # Replace zero values with a large number to exclude them from comparison
  nonZeroVector1 <- ifelse(vector1 == 0, Inf, vector1)
  nonZeroVector2 <- ifelse(vector2 == 0, Inf, vector2)
  
  # Use pmin to find the minimum values
  result <- pmin(nonZeroVector1, nonZeroVector2)
  
  return(result)
}

volatilitySmileAsk <- zipMinNonZero(volatilitySmileAskPut, volatilitySmileAskCall)
volatilitySmileBid <- zipMinNonZero(volatilitySmileBidCall, volatilitySmileBidPut)

data <- data.frame(
  Strike = strikePrices,
  volatilitySmileAsk = volatilitySmileAsk,
  volatilitySmileBid = volatilitySmileBid
)

# install.packages("ggplot2")
library(ggplot2)
ggplot(data, aes(x = Strike)) +
  geom_line(aes(y = volatilitySmileBid, color = "Impl. vol. pre Bid"), linetype = "solid", size = 1, alpha = 0.7) +
  geom_line(aes(y = volatilitySmileAsk, color = "Impl. vol. pre Ask"), linetype = "solid", size = 1, alpha = 0.7) +
  geom_vline(xintercept = currentPrice, linetype = "dotted", color = "purple", size = 1, alpha = 0.7) +
  geom_text(aes(x = currentPrice, y = max(volatilitySmileBid, volatilitySmileAsk), label = paste("Aktuálna cena: ", currentPrice)), 
            vjust = 0.5, hjust = -0.5, color = "purple") + 
labs(title = "Volatility Smiles for Bid and Ask Prices",
     x = "Realizačná cena",
     y = "Implikovaná volatilita") +
  scale_color_manual(values = c("blue", "red"), name = "Type") +
  theme_minimal()



