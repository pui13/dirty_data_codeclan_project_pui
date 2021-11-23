# Libraries needed ----

library(tidyverse)
library(janitor)

# Load in data and have a quick look at data ------

decathlon_data <- read_rds("raw_data/decathlon.rds")
glimpse(decathlon_data)

# Cleaning data -------
# this inlcudes making the row name a new column, 
# changing all names to lowercase and cleaning up column names

decathlon_data <- decathlon_data %>%
  rownames_to_column("Name") %>%
  clean_names() %>%
  mutate(name = str_to_lower(name),
         competition = str_to_lower(competition),
         competition = str_replace(competition, "olympicg", "olympics")) %>%
  rename("100m" = "x100m",
         "400m" = "x400m",
         "110m_hurdle" = "x110m_hurdle",
         "1500m" = "x1500m"
  )
  

# Pivoting the data, making an "events" and "results" column -----

clean_decathlon_data <- decathlon_data %>%
  pivot_longer(`100m`:`1500m`, names_to = "event", values_to = "result")

# Save dataset as new CSV

clean_decathlon_data %>%
  write_csv("clean_data/clean_decathlon_data.csv")