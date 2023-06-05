#!/usr/bin/env Rscript

options(repos = list(CRAN="http://cran.rstudio.com/"))
install.packages("pacman")
pacman::p_load("argparser", "dplyr", "data.table", "stringr", "lubridate", "tidyr")

#suppressPackageStartupMessages(library(argparser))
#suppressPackageStartupMessages(library(dplyr))
#suppressPackageStartupMessages(library(data.table))
#suppressPackageStartupMessages(library(stringr))
#suppressPackageStartupMessages(library(lubridate))
#suppressPackageStartupMessages(library(tidyr))

## read in command line arguments
p <- arg_parser('Case incidence-informed subsampling at monthly and country-level (variant-specific, even-temporally-distributed)')
p <- add_argument(p, 'variant', help='Variant to be studied (allowed options: Alpha, Beta, Gamma, Delta, Epsilon, Zeta, Eta, Theta, Iota, Kappa, Lambda, Mu, Omicron, GH/490R)')
p <- add_argument(p, 'target_num', help='target number of sequences to be subsampled')
p <- add_argument(p, '--start_month', help='starting month (format %Y-%m)')
p <- add_argument(p, '--end_month', help='ending month (format %Y-%m)')
p <- add_argument(p, '--metadata_infile', help='TSV input file containing processed GISAID metadata')
p <- add_argument(p, '--case_data_infile', help='CSV input file containing processed OWID COVID-19 case data')
p <- add_argument(p, '--outfile', help='CSV output file', default='./subsampled_gisaid_metadata.tsv')
argv <- parse_args(p)

## check if specified variant is allowed
variant <- str_to_title(as.character(argv$variant))
allowed_vocs <- c(
  'Alpha',
  'Beta',
  'Gamma',
  'Delta',
  'Epsilon',
  'Zeta',
  'Eta',
  'Theta',
  'Iota',
  'Kappa',
  'Lambda',
  'Mu',
  'Omicron',
  'GH/490R'
)
if (!variant %in% allowed_vocs) {
  stop('specific variant is not allowed')
}

## check that specified starting/ending months are appropriate
read_input_month <- function(x) {
  month <- as.Date(sprintf('%s-01', as.character(x)))
  return(month)
}
# start_month <- as.Date('2020-10-01')
# end_month <- as.Date('2021-06-01')
tryCatch(
  {
    function() {
      start_month <<- read_input_month(argv$start_month)
      end_month <<- read_input_month(argv$end_month)
      if (end_month <= start_month) {
        stop('specific starting/ending month is not allowed')
      }
    } 
  },
  error=function(e) {
    stop('specific starting/ending month is not allowed')
  }
)()
all_months <- seq(start_month, end_month, by='1 month')

## compute target number of sequences to be sampled per month
target_seq_num <- as.numeric(argv$target_num)
target_monthly_seq_num <- target_seq_num/length(all_months)

## read in GISAID metadata
metadata_infile <- as.character(argv$metadata_infile)
gisaid_metadata.df <- read.csv(metadata_infile, sep='\t', stringsAsFactors=FALSE)

## read in OWID data
owid_case_data_infile <- argv$case_data_infile
owid_case_data.df <- read.csv(owid_case_data_infile, sep=',', stringsAsFactors=FALSE)

## apply common country names mapping
## TODO: create separate script for this
# setdiff(unique(gisaid_metadata.df$Country), unique(owid_case_data.df$location))
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'USA'] <- 'United States'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'Bonaire'] <- 'Bonaire Sint Eustatius and Saba'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'Sint Eustatius'] <- 'Bonaire Sint Eustatius and Saba'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'Guadeloupe'] <- 'France'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'Martinique'] <- 'France'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'U.S. Virgin Islands'] <- 'United States Virgin Islands'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'Mayotte'] <- 'France'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'Canary Islands'] <- 'Spain'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'Saint Barthelemy'] <- 'France'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'Cabo Verde'] <- 'Cape Verde'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'French Guiana'] <- 'France'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'Saint Martin'] <- 'France'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'Reunion'] <- 'France'
gisaid_metadata.df$Country[gisaid_metadata.df$Country == 'Crimea'] <- 'Ukraine'
owid_case_data.df$location[owid_case_data.df$location == 'Czechia'] <- 'Czech Republic'
owid_case_data.df$location[owid_case_data.df$location == 'Sint Maarten (Dutch part)'] <- 'Sint Maarten'
owid_case_data.df$location[owid_case_data.df$location == 'Democratic Republic of Congo'] <- 'Democratic Republic of the Congo'
owid_case_data.df$location[owid_case_data.df$location == 'Congo'] <- 'Republic of the Congo'
owid_case_data.df$location[owid_case_data.df$location == 'Timor'] <- 'Timor-Leste'
owid_case_data.df$location[owid_case_data.df$location == 'Bahamas'] <- 'The Bahamas'
owid_case_data.df$location[owid_case_data.df$location == 'Wallis and Futuna'] <- 'Wallis and Futuna Islands'

## calculate monthly/country-level variant proportion
gisaid_metadata_agg.df <- gisaid_metadata.df %>%
  mutate(VOC_of_interest=(VOC == variant)) %>%
  group_by(Collection.date, Country, VOC_of_interest) %>%
  summarise(count=n()) %>%
  mutate(month=floor_date(as.Date(Collection.date), unit='month')) %>%
  group_by(Country, month, VOC_of_interest) %>%
  summarise(count=sum(count))
gisaid_metadata_agg_variant_prop.df <- gisaid_metadata_agg.df %>%
  filter(VOC_of_interest) %>%
  rename(variant_count=count) %>%
  left_join(gisaid_metadata_agg.df %>%
              filter(!VOC_of_interest) %>%
              rename(other_variants_count=count), by=c('Country', 'month')) %>%
  mutate(other_variants_count=ifelse(is.na(other_variants_count), 0, other_variants_count)) %>%
  mutate(variant_prop=variant_count/(variant_count + other_variants_count)) %>%
  select(Country, month, variant_count, variant_prop)

## calculate monthly/country-level case incidence
owid_case_data_agg.df <- owid_case_data.df %>%
  mutate(month=floor_date(as.Date(date), unit='month')) %>%
  group_by(location, month) %>%
  summarise(new_cases=sum(new_cases)) %>%
  rename(Country=location)

## calculate variant-proportion-weighted case incidence
## remove rows with NAs
variant_weighted.new_cases.df <- gisaid_metadata_agg_variant_prop.df %>%
  left_join(owid_case_data_agg.df, by=c('Country', 'month')) %>%
  mutate(variant_weighted_new_cases=new_cases*variant_prop) %>%
  arrange(Country, month) %>%
  filter(month >= start_month & month <= end_month) %>%
  drop_na() %>%
  group_by(month) %>%
  mutate(variant_weighted_new_cases_country_prop=variant_weighted_new_cases/sum(variant_weighted_new_cases))

## allocate target_monthly_seq_num among countries within each month
variant_weighted.new_cases.df[['target_num']] <- 0
gisaid_metadata.df <- gisaid_metadata.df %>%
  mutate(Collection.month=floor_date(as.Date(Collection.date), unit='month'))
sampled_accessions <- c()
for (month_select in all_months) {
  print(month_select)
  month_dat.tmp <- variant_weighted.new_cases.df %>%
    filter(month==month_select)
  if (nrow(month_dat.tmp) > 0) {
    country_samples <- sample(month_dat.tmp$Country, target_monthly_seq_num,
                              prob=month_dat.tmp$variant_weighted_new_cases_country_prop, replace=TRUE)
    country_target_nums <- as.numeric(sapply(month_dat.tmp$Country, function(x) sum(country_samples == x)))
    ## sample sequences for each country for each month
    i <- 1
    for (country in month_dat.tmp$Country) {
      avail_seqs_num <- month_dat.tmp[month_dat.tmp$Country == country,]$variant_count
      target_num <- min(avail_seqs_num, country_target_nums[i])
      seq_index_samples <- sample(seq(1, avail_seqs_num, 1), target_num)
      tmp_sampled_accessions <- gisaid_metadata.df[gisaid_metadata.df$VOC == variant &
                                                     gisaid_metadata.df$Collection.month == month_select &
                                                     gisaid_metadata.df$Country == country,][seq_index_samples,]$Accession.ID
      sampled_accessions <- c(sampled_accessions, tmp_sampled_accessions)
      i <- i+1
    }
    ## record target_num for each country in each month
    variant_weighted.new_cases.df[
      variant_weighted.new_cases.df$month == month_select,]$target_num <- country_target_nums
  }
}

## extract metadata of sampled sequences
gisaid_metadata_sampled.df <- gisaid_metadata.df[gisaid_metadata.df$Accession.ID %in% sampled_accessions,]


## write to file
output_file <- argv$outfile
write.table(gisaid_metadata_sampled.df, file=output_file, row.names=FALSE, quote=FALSE, sep='\t')

