#!/usr/bin/env bash 
script_name=$0 #this denotes name of the shell script

# This is a test script designed to test that everything works in the various
# accessory scripts in this package. Parameters used have absolutely NO
# relation to best practice and this should not be taken as a sensible
# parameterisation for a workflow.

function usage {
    echo "usage: cellassign_post_install_tests.sh [action] [use_existing_outputs]"
    echo "  - action: what action to take, 'test' or 'clean'"
    echo "  - use_existing_outputs, 'true' or 'false'"
    exit 1
}

action=${1:-'test'}
use_existing_outputs=${2:-'false'}

if [ "$action" != 'test' ] && [ "$action" != 'clean' ]; then
    echo "Invalid action"
    usage
fi

if [ "$use_existing_outputs" != 'true' ] && [ "$use_existing_outputs" != 'false' ]; then
    echo "Invalid value ($use_existing_outputs) for 'use_existing_outputs'"
    usage
fi

test_working_dir=`pwd`/'post_install_tests'
output_dir=$test_working_dir/outputs

# Clean up if specified
if [ "$action" = 'clean' ]; then
    echo "Cleaning up $test_working_dir ..."
    rm -rf $test_working_dir
    exit 0
elif [ "$action" != 'test' ]; then
    echo "Invalid action '$action' supplied"
    exit 1
fi 

# Initialise directories
mkdir -p $test_working_dir
mkdir -p $output_dir


################################################################################
# List tool outputs/inputs & parameters 
################################################################################
export test_sce=$test_working_dir/'pollen_cpm.rds'
export processed_sce=$output_dir/'pollen_cpm.rds'

marker_test_data_url='ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/atlas/sc_experiments/E-MTAB-5727/E-MTAB-5727.marker_genes_9.tsv'
export input_marker_file= $test_working_dir/`basename $marker_test_data_url`

export filtered_marker_file=$output_dir/'markers_filtered.tsv'
export processed_marker_file=$output_dir/'markers_processed.tsv'
export output_labels=$output_dir/'labels.txt'


### Workflow parameters

export normalised_counts_slot='normcounts'
export marker_filter_field='pvals_adj'
export thres_filter=0.05


################################################################################
# Test individual scripts
################################################################################

# Make the script options available to the tests so we can skip tests e.g.
# where one of a chain has completed successfullly.

export use_existing_outputs

# Derive the tests file name from the script name

tests_file="${script_name%.*}".bats

# Execute the bats tests
$tests_file