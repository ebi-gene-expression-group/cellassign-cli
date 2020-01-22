#!/usr/bin/env Rscript 

suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(workflowscriptscommon))
#suppressPackageStartupMessages(require(caret))
suppressPackageStartupMessages(require(SingleCellExperiment))
suppressPackageStartupMessages(require(scater))
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
    c("-t", "--normalised-counts-slot"),
    action = "store",
    default = "normcounts",
    type = 'character',
    help = 'Name of the slot with normalised counts matrix in SCE object. Default: normcounts'
  ),

  make_option(
    c("-t", "--log-transformed-counts-slot"),
    action = "store",
    default = "logcounts",
    type = 'character',
    help = 'Name of the slot with log transformed counts matrix in SCE object. Default: logcounts'
  ),
  
  make_option(
    c("-m", "--output-sce-object"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the output matrix object in .rds format'
  )
)

opt = wsc_parse_args(option_list)
# read SCE
sce = readRDS(opt$input_sce_object)

# Compute CPM normalization
if(opt$normalised_counts_slot %in% names(assays(sce))){
  normcounts(sce) <- calculateCPM(sce, exprs_values = "counts")
} 

#log transformation 
if(opt$--log-transformed-counts-slot %in% names(assays(sce))){
  logcounts(sce) <- log2(normcounts(sce)  + 1)
}

#compute size factors
sce <- computeSumFactors(sce, assay.type = "logcounts")
print(sce)

# save object
saveRDS(sce, file=opt$--output-sce-object)
