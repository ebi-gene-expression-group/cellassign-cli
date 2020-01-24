#!/usr/bin/env Rscript 

suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(workflowscriptscommon))
suppressPackageStartupMessages(require(cellassign))
suppressPackageStartupMessages(require(SingleCellExperiment))
suppressPackageStartupMessages(require(scran))
suppressPackageStartupMessages(require(tensorflow))

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
    c("-n", "normalised_counts_slot"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Name of the slot with normalised counts matrix in SCE object. Default: normcounts'
  ),

  make_option(
    c("-m", "--marker-gene-file"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Path to the binary marker gene file in .txt format'
  ),

  make_option(
    c("-o", "--cell-type-labels"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'Output table with cell labels'
  ),
  
  make_option(
    c("-p", "--MLE-params"),
    action = "store",
    default = NA,
    type = 'character',
    help = 'RDS object with maximum likelihood estimates (MLE) of the prediction'
  )
)

opt = wsc_parse_args(option_list)
# read SCE
sce = readRDS(opt$input_sce_object)

#read marker gene file
markers = read.table(opt$marker_gene_file, sep = "\t")

# Compute cell size factors
if(!(opt$normalised_counts_slot %in% names(assays(sce)))){
   sce <- computeSumFactors(sce, exprs_values = "counts")
}else{
    sce <- computeSumFactors(sce, exprs_values = opt$normalised_counts_slot)
    }
s <- sizeFactors(sce)
#TO DO: check presence of covariate matrix 
#TO DO: if present, include it in cell assign function

#Compute CellAssign

#It is critical that gene expression data containing only marker genes is used as input to cellassign. 
#We do this here by subsetting the input SingleCellExperiment using the row names (gene names) of the marker matrix. 
#This also ensures that the order of the genes in the gene expression data matches the order of the genes in the marker matrix.



#Output_1: Cell labels

#Output_2: MLE params
