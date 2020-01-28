#!/usr/bin/env Rscript 

#This script computes library size factors of the scater prreprocessed SCE object. 

suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(workflowscriptscommon))
suppressPackageStartupMessages(require(SingleCellExperiment))
#suppressPackageStartupMessages(require(scater))
suppressPackageStartupMessages(require(scran))

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
    c("-n", "--normalised-counts-slot"),
    action = "store",
    default = "normcounts",
    type = 'character',
    help = 'Name of the slot with log normalised counts matrix in SCE object. Default: normcounts'
  ),
  make_option(
    c("-o", "--output-sce-object"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the output matrix object in .rds format'
  )
)

opt = wsc_parse_args(option_list, mandatory = c("input_sce_object",  "output_sce_object"))
# read SCE
sce = readRDS(opt$input_sce_object)


# Remove cells with no genes expressed and genes non-expressed in any cell
#sce  <- sce[apply(counts(sce), 1, function(x) sum(x > 0) > 0), apply(counts(sce), 2, function(x) sum(x > 0) > 0)]

# Compute cell size factors
if(!(opt$normalised_counts_slot %in% names(assays(sce)))){
   sce <- computeSumFactors(sce, exprs_values = "counts")
}else{
    sce <- computeSumFactors(sce, exprs_values = opt$normalised_counts_slot)
    }

# save object
saveRDS(sce, file = opt$output_sce_object)
