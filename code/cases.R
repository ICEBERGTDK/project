rm(list = ls())
setwd("F:/IC/project/Sar-CoV2/code/")
#install.packages("covidregionaldata")
#library(covidregionaldata)
library(dplyr)
library(ggplot2)
library(scales)

#start_using_memoise()

#> Using a cache at: /var/folders/68/22ndk9854tq394wl_n1cxzlr0000gn/T//RtmpylL81U

#stop_using_memoise()
#reset_cache()

#nots <- get_national_data()

#> Downloading data from https://covid19.who.int/WHO-COVID-19-global-data.csv
#> Cleaning data
#> Processing data

#nots

#COM7 <- c("United States", "United Kingdom", "France", "Germany",
#  "Italy", "Canada", "China"
#)
#COM7_nots <- get_national_data(countries = COM7, verbose = FALSE)
#write.csv(COM7_nots,"F:/IC/project/Sar-CoV2/data/COM7_data.csv")

df <- read.csv("F:/IC/project/Sar-CoV2/data/COM7_data.csv")
df <- select(df,-X)
df$date <- as.Date(df$date)

dev.new()

#COM7_nots %>%
#  ggplot() +
#  aes(x = date, y = cases_new) +
#  geom_line(alpha = 0.4) + facet_wrap(~ country, ncol = 2)+
#  labs(x = "Date", y = "Reported Covid-19 new_cases") +
#  scale_y_continuous(labels = comma) +
#  theme_minimal() +
#  theme(legend.position = "top") +
#  guides(col = guide_legend(title = "country"))


df %>%
  ggplot() +
  aes(x = date, y = cases_new, group = 1)+ 
  geom_line(alpha = 0.4) + facet_wrap(~ country, ncol = 2)+
  labs(x = "Date", y = "Reported Covid-19 new_cases") +
  scale_y_continuous(labels = comma) +
  theme_minimal() +
  theme(legend.position = "top") +
  guides(col = guide_legend(title = "country"))

ggsave("F:/IC/project/Sar-CoV2/result/New_cases.png")

dev.off()

