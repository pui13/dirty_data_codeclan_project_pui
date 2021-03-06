# Packages ------

library(tidyverse)
library(readxl)
library(janitor)

# Read in data -----

candy_2015 <- read_excel("raw_data/boing-boing-candy-2015.xlsx")
candy_2016 <- read_excel("raw_data/boing-boing-candy-2016.xlsx")
candy_2017 <- read_excel("raw_data/boing-boing-candy-2017.xlsx")

# Clean column names -----

candy_2015 <- clean_names(candy_2015)
candy_2016 <- clean_names(candy_2016)
candy_2017 <- clean_names(candy_2017)

#2005 ------
## Renaming and removing unnecessary columns ------

clean_candy_2015 <- select(
  candy_2015,
  -c(
    please_leave_any_remarks_or_comments_regarding_your_choices:
      sea_salt_flavored_stuff_probably_chocolate_since_this_is_the_it_flavor_of_the_year,
    which_day_do_you_prefer_friday_or_sunday:
      please_estimate_the_degrees_of_separation_you_have_from_the_following_folks_beyonce_knowles
  )
) %>%
  rename(
    going_trick_or_treating = are_you_going_actually_going_trick_or_treating_yourself,
    age = how_old_are_you,
    free_restaurant_candy =
      candy_that_is_clearly_just_the_stuff_given_out_for_free_at_restaurants,
    hfcs_vials =
      vials_of_pure_high_fructose_corn_syrup_for_main_lining_into_your_vein,
    marshmallow_circus_peanuts =
      those_odd_marshmallow_circus_peanut_things,
    chick_o_sticks = chick_o_sticks_we_don_t_know_what_that_is,
    `100_grand_bar` = x100_grand_bar,
    boxo_raisins = box_o_raisins
  ) %>%
## Pivot dataset and add extra columns in prep for binding tables -------
pivot_longer(c(butterfinger:necco_wafers),
             names_to = "candy",
             values_to = "rating") %>%
  mutate(
    year = 2015,
    gender = NA,
    country = NA,
    rating = tolower(rating)
  ) %>%
  select(-timestamp)

# 2016 -----
## Renaming and removing unnecessary columns ----

clean_candy_2016 <- select(
  candy_2016,
  -c(
    please_list_any_items_not_included_above_that_give_you_joy:york_peppermint_patties_ignore,
    which_state_province_county_do_you_live_in
  )
) %>%
  rename(
    going_trick_or_treating = are_you_going_actually_going_trick_or_treating_yourself,
    age = how_old_are_you,
    gender = your_gender,
    country = which_country_do_you_live_in,
    free_restaurant_candy =
      candy_that_is_clearly_just_the_stuff_given_out_for_free_at_restaurants,
    hfcs_vials =
      vials_of_pure_high_fructose_corn_syrup_for_main_lining_into_your_vein,
    sourpatch_kids = sourpatch_kids_i_e_abominations_of_nature,
    marshmallow_circus_peanuts =
      those_odd_marshmallow_circus_peanut_things,
    chick_o_sticks = chick_o_sticks_we_don_t_know_what_that_is,
    `100_grand_bar` = x100_grand_bar
  ) %>%
  
  ## Pivot dataset and add extra columns in prep for binding tables -------

pivot_longer(
  c(`100_grand_bar`:york_peppermint_patties),
  names_to = "candy",
  values_to = "rating"
) %>%
  mutate(year = 2016,
         rating = tolower(rating)) %>%
  select(-timestamp)

# 2017 ------
## removing the question number at the start of each column------

(names(candy_2017) = gsub(
  pattern = "q[0-9]*_",
  replacement = "",
  x = names(candy_2017)
))

## Renaming and removing unnecessary columns ----

clean_candy_2017 <- select(candy_2017,
                           -c(joy_other:click_coordinates_x_y,
                              state_province_county_etc)) %>%
  rename(
    going_trick_or_treating = going_out,
    free_restaurant_candy =
      candy_that_is_clearly_just_the_stuff_given_out_for_free_at_restaurants,
    hfcs_vials =
      vials_of_pure_high_fructose_corn_syrup_for_main_lining_into_your_vein,
    sourpatch_kids = sourpatch_kids_i_e_abominations_of_nature,
    marshmallow_circus_peanuts =
      those_odd_marshmallow_circus_peanut_things,
    chick_o_sticks = chick_o_sticks_we_don_t_know_what_that_is,
    mary_janes =
      anonymous_brown_globs_that_come_in_black_and_orange_wrappers_a_k_a_mary_janes
  ) %>%
  
  ## Pivot dataset and add extra columns in prep for binding tables -------

pivot_longer(
  c(`100_grand_bar`:york_peppermint_patties),
  names_to = "candy",
  values_to = "rating"
) %>%
  mutate(year = 2017,
         rating = tolower(rating)) %>%
  select(-internal_id)

# Binding all 3 datasets together -----

all_candy <-
  bind_rows(clean_candy_2015, clean_candy_2016, clean_candy_2017)

# Combined data -----
## Clean up country spellings so they all match for United States, Canada, Uk -----

usa_names <- str_c(
  "usa",
  "state",
  "merica",
  "united s",
  "u.s",
  "us",
  "murica",
  "aayy",
  "alaska",
  "calif",
  "trump",
  "rika",
  "carolina",
  "new york",
  "pitts",
  "amerca",
  "cascadia",
  "new jersey",
  sep = "|"
)

canada_names <- str_c("canae", "canuck", "can", sep = "|")

uk_names <- str_c("uk",
                  "united kin",
                  "scotland",
                  "endland",
                  "england",
                  "god's country",
                  "u.k",
                  sep = "|")

other_names <- str_c("united states", "uk", "canada", sep = "|")

clean_all_candy <- all_candy %>%
  mutate(
    country = tolower(country),
    country = if_else(str_detect(country, usa_names),
                      "united states", country),
    country = if_else(str_detect(country, canada_names),
                      "canada", country),
    country = if_else(str_detect(country, uk_names),
                      "uk", country),
    country = if_else(!str_detect(country, other_names),
                      "other", country),
    country = replace_na(country, "other")
  )

## Filter out ages outside reasonable range, make ages outside of range as NA -----

clean_all_candy$age <- as.numeric(clean_all_candy$age)
clean_all_candy <- clean_all_candy %>%
  mutate(age = if_else(age %in% 4:90, age, as.numeric(NA)))

## Removed any rows which didn't contain candy ------

remove_candy <-
  str_c(
    "vicodin",
    "bread",
    "kale_smoothie",
    "chardonnay",
    "acetam",
    "season",
    "physical",
    "cash",
    "healthy_fruit",
    "board_game",
    "comics",
    "glow_sticks",
    "blue",
    "red",
    "green",
    "independent",
    "abstained",
    "lapel",
    "dental",
    "glow",
    "chalk",
    "third",
    sep = "|"
  )


clean_all_candy <- clean_all_candy %>%
  filter(!str_detect(candy, remove_candy))

## write cleaned data to a new csv -----
clean_all_candy %>%
  write_csv("clean_data/clean_all_candy.csv")
