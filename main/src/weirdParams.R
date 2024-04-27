install.packages("animation")
library(animation)
# skusime rozdne parametre pre aplha, theta, sigma a uvidime co to bude robit s modelom ...
# trocha narychlo spravene ..
weirdAlpha <- mleVasicek$alpha
weirdTheta <- mleVasicek$thetha
weirdSigma <- mleVasicek$sigma

saveGIF({
  for (weirdAlpha in seq(0.01, 3, by = 0.01)) {
    sigma_t <- sqrt(weirdSigma^2 * (T - t) - 2 * weirdSigma^2 * (1 - exp(-(T - t))) + weirdSigma^2 * (1 - exp(-2*(T - t))))
    P_t <- exp(
      - ((weirdTheta / weirdAlpha) * (T - t) +
           1/weirdAlpha * (rateClose - weirdTheta / weirdAlpha) * (1 - exp(-weirdAlpha * (T - t))) -
           1/2 * sigma_t^2)
    )
    theoreticalFuturesPrice <- futuresPrice(exchangeSpotDataClose, P_t , weirdSigma, weirdAlpha, 1, sigHat, corHat, t)
    data <- data.frame(t, exchangeSpotDataClose, exchangeFutureClosePrice, theoreticalFuturesPrice, theorethicalForwardPrice)
    plotResult <- ggplot(data) +
      geom_line(aes(x = t, y = exchangeFutureClosePrice, color = 'Burzová cena f_t'), linetype = 'solid') +
      geom_line(aes(x = t, y = exchangeSpotDataClose, color = 'S_t'), linetype = 'solid') +
      geom_line(aes(x = t, y = theorethicalForwardPrice, color = 'Teoretická cena F_t'), linetype = 'solid') +
      geom_line(aes(x = t, y = theoreticalFuturesPrice, color = 'Teoretická cena f_t'), linetype = 'solid') +
      labs(
        title = paste("Porovnanie cien (weirdAlpha =", round(weirdAlpha, 3), ", weirdTheta =", round(weirdTheta, 3), ", weirdSigma =", round(weirdSigma, 3), ")"),
        x = "t",
        y = "cena",
        caption = "Porovnanie vývoja cien"
      ) +
      scale_color_manual(
        values = c('Burzová cena f_t' = 'green', 'S_t' = 'red', 'Teoretická cena f_t' = 'pink', 'Teoretická cena F_t' = 'blue'),
        labels = c('Burzová cena f_t', 'S_t', 'Teoretická cena f_t', 'Teoretická cena F_t')
      ) +
      theme(
        plot.title = element_text(size = rel(0.8))
      )
    print(plotResult)
    cat("Current values: weirdAlpha =", weirdAlpha, ", weirdTheta =", weirdTheta, ", weirdSigma =", weirdSigma, "\n")
  }
}, movie.name = "zvysoavanieAlphy.gif", interval = 0.1)

# Reset values
weirdAlpha <- mleVasicek$alpha
weirdTheta <- mleVasicek$thetha
weirdSigma <- mleVasicek$sigma

saveGIF({
  for (weirdTheta in seq(0.1, 3, by = 0.01)) {
    sigma_t <- sqrt(weirdSigma^2 * (T - t) - 2 * weirdSigma^2 * (1 - exp(-(T - t))) + weirdSigma^2 * (1 - exp(-2*(T - t))))
    P_t <- exp(
      - ((weirdTheta / weirdAlpha) * (T - t) +
           1/weirdAlpha * (rateClose - weirdTheta / weirdAlpha) * (1 - exp(-weirdAlpha * (T - t))) -
           1/2 * sigma_t^2)
    )
    theoreticalFuturesPrice <- futuresPrice(exchangeSpotDataClose, P_t , weirdSigma, weirdAlpha, 1, sigHat, corHat, t)
    data <- data.frame(t, exchangeSpotDataClose, exchangeFutureClosePrice, theoreticalFuturesPrice, theorethicalForwardPrice)
    plotResult <- ggplot(data) +
      geom_line(aes(x = t, y = exchangeFutureClosePrice, color = 'Burzová cena f_t'), linetype = 'solid') +
      geom_line(aes(x = t, y = exchangeSpotDataClose, color = 'S_t'), linetype = 'solid') +
      geom_line(aes(x = t, y = theorethicalForwardPrice, color = 'Teoretická cena F_t'), linetype = 'solid') +
      geom_line(aes(x = t, y = theoreticalFuturesPrice, color = 'Teoretická cena f_t'), linetype = 'solid') +
      labs(
        title = paste("Porovnanie cien (weirdAlpha =", round(weirdAlpha, 3), ", weirdTheta =", round(weirdTheta, 3), ", weirdSigma =", round(weirdSigma, 3), ")"),
        x = "t",
        y = "cena",
        caption = "Porovnanie vývoja cien"
      ) +
      scale_color_manual(
        values = c('Burzová cena f_t' = 'green', 'S_t' = 'red', 'Teoretická cena f_t' = 'pink', 'Teoretická cena F_t' = 'blue'),
        labels = c('Burzová cena f_t', 'S_t', 'Teoretická cena f_t', 'Teoretická cena F_t')
      ) +
      theme(
        plot.title = element_text(size = rel(0.8))
      )
    print(plotResult)
    cat("Current values: weirdAlpha =", weirdAlpha, ", weirdTheta =", weirdTheta, ", weirdSigma =", weirdSigma, "\n")
  }
}, movie.name = "zvysovanieThety.gif", interval = 0.1)

# Reset values
weirdAlpha <- mleVasicek$alpha
weirdTheta <- mleVasicek$thetha
weirdSigma <- mleVasicek$sigma

saveGIF({
  for (weirdSigma in seq(0.01, 3, by = 0.01)) {
    sigma_t <- sqrt(weirdSigma^2 * (T - t) - 2 * weirdSigma^2 * (1 - exp(-(T - t))) + weirdSigma^2 * (1 - exp(-2*(T - t))))
    P_t <- exp(
      - ((weirdTheta / weirdAlpha) * (T - t) +
           1/weirdAlpha * (rateClose - weirdTheta / weirdAlpha) * (1 - exp(-weirdAlpha * (T - t))) -
           1/2 * sigma_t^2)
    )
    theoreticalFuturesPrice <- futuresPrice(exchangeSpotDataClose, P_t , weirdSigma, weirdAlpha, 1, sigHat, corHat, t)
    data <- data.frame(t, exchangeSpotDataClose, exchangeFutureClosePrice, theoreticalFuturesPrice, theorethicalForwardPrice)
    plotResult <- ggplot(data) +
      geom_line(aes(x = t, y = exchangeFutureClosePrice, color = 'Burzová cena f_t'), linetype = 'solid') +
      geom_line(aes(x = t, y = exchangeSpotDataClose, color = 'S_t'), linetype = 'solid') +
      geom_line(aes(x = t, y = theorethicalForwardPrice, color = 'Teoretická cena F_t'), linetype = 'solid') +
      geom_line(aes(x = t, y = theoreticalFuturesPrice, color = 'Teoretická cena f_t'), linetype = 'solid') +
      labs(
        title = paste("Porovnanie cien (weirdAlpha =", round(weirdAlpha, 3), ", weirdTheta =", round(weirdTheta, 3), ", weirdSigma =", round(weirdSigma, 3), ")"),
        x = "t",
        y = "cena",
        caption = "Porovnanie vývoja cien"
      ) +
      scale_color_manual(
        values = c('Burzová cena f_t' = 'green', 'S_t' = 'red', 'Teoretická cena f_t' = 'pink', 'Teoretická cena F_t' = 'blue'),
        labels = c('Burzová cena f_t', 'S_t', 'Teoretická cena f_t', 'Teoretická cena F_t')
      ) +
      theme(
        plot.title = element_text(size = rel(0.8))
      )
    print(plotResult)
    cat("Current values: weirdAlpha =", weirdAlpha, ", weirdTheta =", weirdTheta, ", weirdSigma =", weirdSigma, "\n")
  }
}, movie.name = "zvysovanieSigmy.gif", interval = 0.1)
