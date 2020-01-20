#!/usr/bin/env Rscript 


suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(workflowscriptscommon))
#suppressPackageStartupMessages(require(caret))
suppressPackageStartupMessages(require(SingleCellExperiment))


# argument parsing 
option_list = list(
    make_option(
    c("-i", "--input-sce-object"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the input SCE object in .rds format'
  )
)

opt = wsc_parse_args(option_list)

sce = readRDS(opt$input_sce_object)

print(sce)