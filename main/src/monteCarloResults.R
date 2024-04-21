library(tidyverse)
install.packages(c('hrbrthemes','viridis'))
library(hrbrthemes)
library(viridis)
corr_friends_monte_carlo_result <- read.csv('../src/tradingStartegies/data/fromSrc/corr_friends_on_monte_carlo.csv', header = TRUE, sep = ',')
if (!is.data.frame(corr_friends_monte_carlo_result)) {
  corr_friends_monte_carlo_result <- as.data.frame(corr_friends_monte_carlo_result)
}

data <- data.frame(
  name=corr_friends_monte_carlo_result[,1],
  value=corr_friends_monte_carlo_result[,2]
)



# grouped boxplot
ggplot(data, aes(x=variety, y=note, fill=treatment)) + 
  geom_boxplot()



pdf(file="saving_plot4.pdf")
boxplot(corr_friends_monte_carlo_result[,1],
        names = c("Výsledny stav účtu"),
        col = c("blue" ),
        ylab = "$",
        main = "Boxplot pre výsledný profit")
dev.off()

pdf(file="saving_plot4.pdf")
boxplot(corr_friends_monte_carlo_result[,2] * 100,
             names = c("Maximálny prepad"),
             col = c("blue" ),
             ylab = "%",
             main = "Boxplot pre záznam maximálneho prepadu")
ggsave("boxplot_mad_drawdawn_corr_friends_monte_carlo.pdf", plot = b)
dev.off()
