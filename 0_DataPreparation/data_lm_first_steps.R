library("readr")
library("dplyr")
library("lubridate")

d1 <- read_csv("0_DataPreparation/umsatzdaten_gekuerzt.csv")
d2 <- read_csv("0_DataPreparation/kiwo.csv")
d3 <- read_csv("0_DataPreparation/wetter.csv")
d4 <- read_csv("0_DataPreparation/schulferien.csv")

data <- d1 %>%
  left_join(d2, by = "Datum") %>%
  left_join(d3, by = "Datum") %>%
  left_join(d4, by = "Datum")

data <- data %>%
  mutate(Wochenende = ifelse(wday(Datum) %in% c(1, 7), 1, 0))

mod <- lm(Umsatz ~ as.factor(Warengruppe) + Temperatur, data)
summary(mod)

mod2 <- lm(Umsatz ~ as.factor(Warengruppe) + Temperatur + Wochenende, data)
summary(mod2) # best model for now with 71,16 %

mod3 <- lm(Umsatz ~ as.factor(Warengruppe) + Temperatur + Wochenende + Windgeschwindigkeit, data)
summary(mod3)

mod4 <- lm(Umsatz ~ as.factor(Warengruppe) + Temperatur + Wochenende + Bewoelkung, data)
summary(mod4)

mod5 <- lm(Umsatz ~ as.factor(Warengruppe) * Temperatur, data)
summary(mod5)

mod6 <- lm(Umsatz ~ as.factor(Warengruppe) * Temperatur * Windgeschwindigkeit, data)
summary(mod6)

