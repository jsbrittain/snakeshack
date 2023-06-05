#!/usr/bin/env Rscript

options(repos = list(CRAN="http://cran.rstudio.com/"))
install.packages("pacman")
pacman::p_load("argparser", "dplyr")
#suppressPackageStartupMessages(library(argparser))
#suppressPackageStartupMessages(library(dplyr))

## read in command line arguments
p <- arg_parser('Preprocess OWID case data')
p <- add_argument(p, 'infile', help='CSV input file containing raw OWID COVID-19 case data')
p <- add_argument(p, '--outfile', help='CSV output file', default='./processed_owid_case_data.csv')
argv <- parse_args(p)

## read in OWID data
input_file <- argv$infile
owid_case_data.df <- read.csv(input_file, sep=',')

## select only relevant columns
relevant_columns <- c(
  'iso_code', 'continent', 'location', 'date', 'new_cases', 'population'
)
owid_case_data.df <- owid_case_data.df %>%
  select(all_of(relevant_columns))
owid_case_data.df$iso_code <- as.character(owid_case_data.df$iso_code)
owid_case_data.df$date <- as.Date(owid_case_data.df$date)
owid_case_data.df$new_cases <- as.numeric(owid_case_data.df$new_cases)

## remove "International" cases
## remove aggregated cases
owid_case_data.df <- owid_case_data.df %>%
  filter(location != 'International' & !startsWith(iso_code, 'OWID'))

## assume NA to be 0
owid_case_data.df$new_cases[is.na(owid_case_data.df$new_cases)] <- 0

## write to file
output_file <- argv$outfile
write.csv(owid_case_data.df, file=output_file, row.names=FALSE, quote=FALSE)


