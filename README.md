
# National and subnational estimates of the time-varying reproduction number for Covid-19

This repository contains estimates of the time-varying reproduction number for every country in the world listed in the ECDC Covid-19 data source and subnational estimates for 9 countries. Summarised estimates can be found in `national/cases/summary` and `national/deaths/summary` (based on cases and deaths respectively). Estimates for each country can be found in `national/cases/national` and `national/deaths/national`. Subnational estimates can be found in the relevant country folder (`subnational/country`) with the same folder structure as for the national estimates. Estimates are generated using [`{EpiNow2}`](https://epiforecasts.io/EpiNow2/) and presented on [epiforecasts.io/covid](https://epiforecasts.io/covid) (which also outlines the method used).

## Updating the estimates

1. Clone the repository.

```bash
git clone https://github.com/epiforecasts/covid-rt-estimates.git
```

### Using Docker

2. Log in to GitHub Docker package repository.

```bash
docker login docker.pkg.github.com
```

#### Script approach


3. (Optional - must be done at least once) Update the docker container.

```bash
sudo bash update-docker.sh
```

3. Run the following in a bash terminal

```bash
sudo bash update-via-docker.sh
```

#### Step by step


3. (Optional) Build the docker container locally.

```bash
docker build . -t covid-rt-estimates
```

4. (Optional). Alternatively pull the built docker container

```bash
docker pull docker.pkg.github.com/epiforecasts/covid-rt-estimates/covidrtestimates:latest
docker tag docker.pkg.github.com/epiforecasts/covid-rt-estimates/covidrtestimates:latest covidrtestimates
```

5. Update the estimates (saving the results to a results folder)

```bash
mkdir results
docker run --rm --user rstudio --mount type=bind,source=$(pwd)/results,target=/home/covid-rt-estimates covidrtestimates /bin/bash bin/update-estimates.sh
```

6. Clean up estimates and remove the temporary folder.

```bash
mv -r -f results/national national
mv -r -f results/subnational subnational
rm -r -f results
```

### Using R

2. Install dependencies.

```r
devtools::install_dev_deps()
```

3. Update national estimates

```r
Rscript R/update-cases.R
Rscript R/update-deaths.R
```

4. Run each `R/update-country.R` script in turn.

## Development environment

This analysis was developed in a docker container based on the `epinow2` docker image.

To build the docker image run (from the `covid-rt-estimates` directory):

``` bash
docker build . -t covidrtestimates
```

Alternatively to use the prebuilt image first login into the GitHub package repository using your GitHub credentials (if you have not already done so) and then run the following:

```bash
# docker login docker.pkg.github.com
docker pull docker.pkg.github.com/epiforecasts/covid-rt-estimates/covidrtestimates:latest
docker tag docker.pkg.github.com/epiforecasts/covid-rt-estimates/covidrtestimates:latest covidrtestimates
```
To run the docker image run:

``` bash
docker run -d -p 8787:8787 --name covidrtestimates -e USER=covidrtestimates -e PASSWORD=covidrtestimates covidrtestimates
```

The rstudio client can be found on port :8787 at your local machines ip.
The default username:password is covidrtestimates:covidrtestimates, set the user with -e
USER=username, and the password with - e PASSWORD=newpasswordhere. The
default is to save the analysis files into the user directory.

To mount a folder (from your current working directory - here assumed to
be `tmp`) in the docker container to your local system use the following
in the above docker run command (as given mounts the whole `covidrtestimates`
directory to `tmp`).

``` bash
--mount type=bind,source=$(pwd)/tmp,target=/home/covidrtestimates
```

To access the command line run the following:

``` bash
docker exec -ti covidrtestimates bash
```