#!/usr/bin/env Rscript 

#This scripts reads the filtered marker gene file and transforms it into the suitable input for cellassign prediction tool.
#Also performs some processing: Filter markers not present in sce rownames.

suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(workflowscriptscommon))

# argument parsing 
option_list = list(
  make_option(
    c("-i", "--input-sce-object"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the input SCE object in rds format'
  ),

    make_option(
    c("-m", "--input-marker-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the marker gene file in tsv format'
  ),
  
  make_option(
    c("-o", "--output-marker-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the output binary marker gene file that serves as input to cellassign'
  )
)

opt = wsc_parse_args(option_list, mandatory = c("input_sce_object", "input_marker_file", "output_marker_file"))

#read SCE
sce <- readRDS(opt$input_sce_object)

#read marker file
markers <- read.table(opt$input_marker_file, sep = "\t", header = T)

#convert to cellassign required format (binary matrix: genes x cell_types/groups)
binary_markers <- table(markers$names, markers$groups)

#Filter markers not present in sce rownames - Critical! 
#This also ensures that the order of the genes in the gene expression data matches the order of the genes in the marker matrix.
markers <- markers[rownames(markers) %in% rownames(sce), ]

#save cellassign marker gene file
write.table(binary_markers, file = opt$output_marker_file, sep = "\t")


