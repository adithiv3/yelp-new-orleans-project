# R/01_import_and_filter.R
# Project 2, steps 1-2: import the Yelp JSON files, filter to New Orleans
# restaurants, and save compressed RDS files. Run from the project root.

library(tidyverse)
library(jsonlite)

business_file <- "data/raw/yelp_academic_dataset_business.json"
review_file   <- "data/raw/yelp_academic_dataset_review.json"
stopifnot(file.exists(business_file), file.exists(review_file))
dir.create("data/new_orleans", recursive = TRUE, showWarnings = FALSE)

# ---- 1. Businesses (about 150,000 rows; fits in memory) ----------------------
cat("Reading business file...\n")
business_raw <- stream_in(file(business_file), verbose = FALSE)

business <- business_raw |>
  select(business_id, name, address, city, state, postal_code,
         latitude, longitude, stars, review_count, categories) |>
  as_tibble()
rm(business_raw); invisible(gc())
cat("Businesses read:", nrow(business), "\n")

# Look at how Louisiana cities are spelled before filtering
business |>
  filter(state == "LA") |>
  count(city, sort = TRUE) |>
  slice_head(n = 15) |>
  print()

# ---- 2. Filter to New Orleans restaurants ------------------------------------
new_orleans_restaurants <- business |>
  filter(
    state == "LA",
    str_squish(city) == "New Orleans",
    !is.na(categories),
    str_detect(categories, regex("Restaurants", ignore_case = TRUE))
  ) |>
  mutate(
    postal_code   = na_if(postal_code, ""),
    categories    = str_squish(categories),
    business_name = str_squish(name)
  ) |>
  distinct(business_id, .keep_all = TRUE)

cat("New Orleans restaurants:", nrow(new_orleans_restaurants), "\n")
saveRDS(new_orleans_restaurants, "data/new_orleans/business_new_orleans.rds", compress = "xz")

# ---- 3. Reviews: stream the huge file in chunks, keep only our restaurants ---
# Only 100,000 reviews are in memory at a time, so a 5 GB file is fine.
cat("Streaming review file (this takes several minutes)...\n")
nola_ids <- new_orleans_restaurants$business_id
kept <- list()
chunk <- 0

keep_nola_reviews <- function(df) {
  chunk <<- chunk + 1
  kept[[chunk]] <<- df |>
    filter(business_id %in% nola_ids) |>
    select(review_id, business_id, user_id, stars, date, text, useful, funny, cool)
  invisible(NULL)
}

stream_in(file(review_file), handler = keep_nola_reviews, pagesize = 100000)
reviews_nola <- bind_rows(kept) |> as_tibble()
rm(kept); invisible(gc())

# ---- 4. Sanity checks --------------------------------------------------------
reviews_nola |>
  summarise(reviews = n(),
            restaurants_with_reviews = n_distinct(business_id),
            reviewers = n_distinct(user_id),
            first_review = min(date), last_review = max(date)) |>
  print()

# Compare with the review_count Yelp reports on each business
new_orleans_restaurants |>
  select(business_id, review_count) |>
  left_join(count(reviews_nola, business_id, name = "reviews_in_file"), by = "business_id") |>
  mutate(reviews_in_file = replace_na(reviews_in_file, 0L)) |>
  summarise(restaurants = n(),
            with_zero_reviews_in_file = sum(reviews_in_file == 0),
            yelp_review_count_total = sum(review_count),
            reviews_in_file_total = sum(reviews_in_file)) |>
  print()

# ---- 5. Save (one version without the review text is small enough for GitHub) -
saveRDS(reviews_nola, "data/new_orleans/reviews_new_orleans_with_text.rds", compress = "xz")
saveRDS(select(reviews_nola, -text), "data/new_orleans/reviews_new_orleans.rds", compress = "xz")

files <- list.files("data/new_orleans", full.names = TRUE)
print(tibble(file = basename(files), MB = round(file.size(files) / 1e6, 1)))