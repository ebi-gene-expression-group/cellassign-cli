#!/usr/bin/env Rscript 

#Script to run the cellassign predictor. Outputs a table with cell IDs and predicted cell labels.
#TO DO: Maybe separate the output extraction as a different process
#TO DO: Include more of the cellassign function as arguments (covariates, learning rate etc)

suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(workflowscriptscommon))

# argument parsing 
option_list = list(
    make_option(
    c("-i", "--input-sce-object"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the input SCE object in .rds format'
  ),
  make_option(
    c("-n", "--normalised_counts_slot"),
    action = "store",
    default = "normcounts",
    type = 'character',
    help = 'Name of the slot with normalised counts matrix in SCE object. Default: normcounts'
  ),
  make_option(
    c("-m", "--marker-gene-file"),
    action = "store",
    default = NULL,
    type = 'character',
    help = 'Path to the binary marker gene file in .txt format'
  ),
  make_option(
    c("-o", "--output-labels"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Output txt file with cell labels'
  )
)

opt <-  wsc_parse_args(option_list = option_list, mandatory = c("input_sce_object", "marker_gene_file", "output_labels"))

#check file exists 
if(!file.exists(opt$input_sce_object)) stop("Input SCE object does not exist.")
if(!file.exists(opt$marker_gene_file)) stop("Input marker file does not exist.")


# read SCE
suppressPackageStartupMessages(require(SingleCellExperiment))
sce <- readRDS(opt$input_sce_object)
#if normalised_counts_slot not present, use counts as assay to infer cell type
if(! opt$normalised_counts_slot %in% names(assay(sce))){
  opt$normalised_counts_slot <- "counts"
}

#read marker gene file
markers <- read.table(opt$marker_gene_file, header = T, sep = "\t")
# Extract cell size factors
s <- sizeFactors(sce)
if(is.null(s) == TRUE) print("Size factors == NULL")

#TO DO: check presence of covariate matrix 
#TO DO: if present, include it in cell assign function

#Compute CellAssign
suppressPackageStartupMessages(require(cellassign))

fit <- cellassign(exprs_obj = sce[rownames(markers),], 
                  marker_gene_info = markers, 
                  s = s, 
                  sce_assay = opt$normalised_counts_slot, 
                  learning_rate = 1e-2, 
                  shrinkage = TRUE,
                  verbose = FALSE)


#Output cell labels
cell_labels <- data.frame("cell id" = colnames(sce), "cell labels" = fit$cell_type)

#save output
write.table(binary_markers, file = opt$output_labels, append = FALSE, sep = " ", dec = ".", row.names = FALSE, col.names = TRUE)
