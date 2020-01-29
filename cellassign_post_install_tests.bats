#!/usr/bin/env bats 

# download test sce object from the link provided in package docs
@test "extract test data" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$test_sce" ]; then
        skip "$test_sce exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $test_sce && get_test_data.R #remove the output when test finishes
    echo "status = ${status}" #exit status
    echo "output = ${output}"

    [ "$status" -eq 0 ] #check if exit status = 0 . This is no error when running.
    [ -f  "$test_sce" ] #cheks if the file is a regular file (not a directory or device file)
  
}

@test "compute sum factors" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$output_sce_processed" ]; then
        skip "$output_sce_processed exists and use_existing_outputs is set to 'true'"
    fi
    run rm -f $output_sce_processed && cellassign_sum_factors.R\
                        --input-sce-object $test_sce\
                        --normalised-counts-slot $normalised_counts_slot\
                        --output-sce-object $processed_sce

    echo "status = ${status}"
    echo "output = ${output}"

    [ "$status" -eq 0 ]
    [ -f  "$output_sce_processed" ]
}

@test "read marker file" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$scPred_object" ]; then
        skip "$output_marker_file exists and use_existing_outputs is set to 'true'"
    fi
    
    run rm -f $output_marker_file &&\
                                cellassign_read_marker_file.R\
                                    --input-marker-file $input_marker_file\
                                    --marker-filter-field $marker_filter_field\
                                    --thres-filter $thres_filter\
                                    --output-marker-file $filtered_marker_file

    echo "status = ${status}"
    echo "output = ${output}"

    [ "$status" -eq 0 ]
    [ -f  "$output_marker_file" ]
}

@test "process marker file" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$output_marker_file" ]; then
        skip "$output_marker_file exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $output_marker_file  &&\ 
                                    cellassign_process_marker_file.R\
                                        --input-sce-object $processed_sce\
                                        --input-marker-file $filtered_marker_file\
                                        --output-marker-file $processed_marker_file 
                                        #doubt! this is the same output name as the previous script, 
                                        #although it is not the same file, may it affect it?

    echo "status = ${status}"
    echo "output = ${output}"

    [ "$status" -eq 0 ]
    [ -f  "$output_marker_file" ]
}

@test "run predictor" {
    if [ "$use_existing_outputs" = 'true' ] && [ -f "$output_labels" ]; then
        skip "$output_labels exists and use_existing_outputs is set to 'true'"
    fi

    run rm -f $output_labels  &&\
                                cellassign_run_predictor.R\
                                    --input-sce-object $processed_sce
                                    --normalised_counts_slot $normalised_counts_slot\
                                    --marker-gene-file $processed_marker_file\
                                    --output-labels $output_labels

    echo "status = ${status}"
    echo "output = ${output}"

    [ "$status" -eq 0 ]
    [ -f  "$output_labels" ]
    
}
