# Packages -----------------------------------------------------------------
require(EpiNow2)
require(covidregionaldata)
require(data.table)
require(future)
require(here)

# Load utils --------------------------------------------------------------

source(here::here("R", "utils.R"))

# Update delays -----------------------------------------------------------

generation_time <- readRDS(here::here("data", "generation_time.rds"))
incubation_period <- readRDS(here::here("data", "incubation_period.rds"))
reporting_delay <- readRDS(here::here("data", "onset_to_admission_delay.rds"))

# Get cases  ---------------------------------------------------------------

cases <- data.table::setDT(covidregionaldata::get_national_data(source = "ecdc"))

cases <- cases[, .(region = country, date = as.Date(date), confirm = cases_new)]
cases <- cases[, .SD[date >= (max(date) - lubridate::weeks(8))], by = region]
data.table::setorder(cases, date)


# Check to see if the data has been updated  ------------------------------

check_for_update(cases, last_run = here::here("last-update", "cases.rds"))

# # Set up cores -----------------------------------------------------

no_cores <- setup_future(length(unique(cases$region)))


# Run Rt estimation -------------------------------------------------------

regional_epinow(reported_cases = cases,
                generation_time = generation_time,
                delays = list(incubation_period, reporting_delay),
                horizon = 14, burn_in = 7,
                samples = 2000, warmup = 500,
                cores = no_cores, chains = 2,
                target_folder = "national/cases/national",
                summary_dir = "national/cases/summary",
                return_estimates = FALSE, verbose = FALSE)