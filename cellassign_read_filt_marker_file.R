#!/usr/bin/env Rscript 

#This scripts reads and filters the marker gene file. 

suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(workflowscriptscommon))

# argument parsing 
option_list = list(

  make_option(
    c("-i", "--input-marker-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the input binary marker gene file required by cell assign'
  ), 

  make_option(
    c("-l", "--marker-filter-field"),
    action = "store",
    default = "pvals_adj", 
    type = 'character',
    help = 'Field of the marker file to perform the marker genes filtering on'
  ),
  
  make_option(
    c("-t", "--thres-filter"),
    action = "store",
    default = 0.05,
    type = 'numeric',
    help = 'P value threshold to filter marker genes'
  ),

  make_option(
    c("-o", "--output-marker-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the output filtered marker gene file'
  )
)

opt <-  wsc_parse_args( option_list = option_list, mandatory = c("input_marker_file", "output_marker_file"))

#check file exists 
if(!file.exists(opt$input_marker_file)) stop("Input file does not exist.")

#read input marker gene file
markers <- read.table(opt$input_marker_file, header = T, sep = "\t")

print(paste0("There are: ", nrow(markers) , "in the input marker gene file"))

#Filter markers based on adjusted p value (default = 0.05)
markers <- markers[markers[[opt$marker_filter_field]] < opt$thres_filter, ]

#TODO: establish some checking system so that the output file is not empty!
if(nrow(markers) == 0)print("Marker gene file has: 0 genes!")

print(paste0("There are: ", nrow(markers) , "in the output marker gene file"))
#Save processed marker file
write.table(x = markers, file = opt$output_marker_file, sep= "\t", row.names = T, col.names = T)
