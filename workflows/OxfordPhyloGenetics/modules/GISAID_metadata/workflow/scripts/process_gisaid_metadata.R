#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(argparser))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(stringr))

## read in command line arguments
p <- arg_parser('Preprocess GISAID metadata')
p <- add_argument(p, 'infile', help='CSV input file containing raw GISAID metadata')
p <- add_argument(p, '--outfile', help='CSV output file', default='./processed_gisaid_metadata.tsv')
argv <- parse_args(p)

## read in GISAID metadata
## function to pre-process GIASAID metadata
GISAID_process <- function(df) {
  by_location <- str_split_fixed(df$Location, " / ", 4)
  colnames(by_location) <- c("Continent", "Country", "State", "City")
  processed.df <- cbind(df, by_location)
  processed.df <- processed.df %>%
    mutate(
      State=trimws(State),
      Country=trimws(Country),
      Collection.date=as.Date(as.character(`Collection date`), "%Y-%m-%d"),
      Submission.date=as.Date(as.character(`Submission date`), "%Y-%m-%d")
    ) %>%
    rename(
      Accession.ID=`Accession ID`,
      Pango.lineage=`Pango lineage`,
      Seq.length=`Sequence length`
    ) %>%
    select(-`Collection date`, -`Submission date`, -Location)
  ## remove sequences without collection date and with travel history
  processed.df <- processed.df %>%
    filter(!is.na(Collection.date) &
             !(grepl('travel', `Additional location information`, ignore.case=TRUE) &
                 !grepl('No International travelling history', `Additional location information`, ignore.case=TRUE))
    ) %>%
    select(-`Additional location information`)
  return (processed.df)
}
input_file <- argv$infile
gisaid_metadata.df = as.data.frame(
  fread(input_file, drop = c(
    "Type", "Host", "Patient age", "Gender", "Clade", "Pangolin version",
    "AA Substitutions", "Is reference?", "Is complete?",
    "Is high coverage?", "Is low coverage?", "N-Content", "GC-Content")))
processed_gisaid_metadata.df <- GISAID_process(gisaid_metadata.df)

## Create Seq.name
processed_gisaid_metadata.df <- processed_gisaid_metadata.df %>%
  mutate(Seq.name=gsub(' ', '_', sprintf('%s|%s|%s', `Virus name`, Accession.ID, as.character(Collection.date))))

## Simplify variant information
voc_map <- data.frame(
  voc_long=unique(processed_gisaid_metadata.df$Variant),
  VOC=sapply(unique(processed_gisaid_metadata.df$Variant), function(x) as.character(str_split(x, ' ')[[1]])[2])
)
voc_map$voc_long <- as.character(voc_map$voc_long)
voc_map$VOC <- as.character(voc_map$VOC)
voc_map[is.na(voc_map$VOC),]$VOC <- 'Unknown'
## merge with processed_gisaid_metadata.df
processed_gisaid_metadata.df <- processed_gisaid_metadata.df %>%
  left_join(voc_map %>% rename(Variant=voc_long), by='Variant') %>%
  select(-Variant)

## write to file
output_file <- argv$outfile
write.table(processed_gisaid_metadata.df, file=output_file, row.names=FALSE, quote=FALSE, sep='\t')
