# Packages -----------------------------------------------------------------
require(EpiNow2, quietly = TRUE)
require(covidregionaldata, quietly = TRUE)
require(data.table, quietly = TRUE)
require(future, quietly = TRUE)
require(lubridate, quietly = TRUE)

# Load utils --------------------------------------------------------------

source(here::here("R", "utils.R"))

# Update delays -----------------------------------------------------------

generation_time <- readRDS(here::here("data", "generation_time.rds"))
incubation_period <- readRDS(here::here("data", "incubation_period.rds"))
reporting_delay <- readRDS(here::here("data", "onset_to_admission_delay.rds"))

# Get cases  ---------------------------------------------------------------

cases <- data.table::setDT(covidregionaldata::get_regional_data(country = "colombia"))

cases <- clean_regional_data(cases[, region := state])

# Check to see if the data has been updated  ------------------------------

check_for_update(cases, last_run = here::here("last-update", "colombia.rds"))

# Set up cores -----------------------------------------------------

no_cores <- setup_future(length(unique(cases$region)))

# Run Rt estimation -------------------------------------------------------

regional_epinow_with_settings(reported_cases = cases,
                generation_time = generation_time,
                delays = list(incubation_period, reporting_delay),
                no_cores = no_cores,
                target_dir = "subnational/colombia/cases/national",
                summary_dir = "subnational/colombia/cases/summary")
