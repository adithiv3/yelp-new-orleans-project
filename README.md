## Data

The raw Yelp JSON files are not committed to this repository (they are several GB).
To reproduce the import:

1. Download the Yelp Open Dataset (JSON) from https://business.yelp.com/data/resources/open-dataset/
2. Extract `yelp_academic_dataset_business.json` and `yelp_academic_dataset_review.json` into `data/raw/`
3. Run `R/01_import_and_filter.R`, which filters to New Orleans restaurants and saves the compressed RDS files in `data/new_orleans/`.