#!/usr/bin/env nextflow

// PRINT PIPELINE HELP AND EXIT
if(params.help){
include { printHelp } from './lib/functions.nf'
printHelp()
}

// PRINT PIPELINE VERSION AND EXIT
if(params.version){
include { printVersion } from './lib/functions.nf'
printVersion()
}

// DEFINE PATHS # these are strings which are used to define input Channels,
// but they are specified here as they may be referenced in LOGGING
file1 = file("/path/to/file1.file", checkIfExists: true, glob: false)
file2 = file("${params.some_parameter}", checkIfExists: true, glob: false)

// PRINT STANDARD LOGGING INFORMATION
include { printLogging } from './lib/functions.nf'
printLogging()


////////////////////
// STAGE CHANNELS //
////////////////////

/*
 *   Channels are where you define the input for the different
 *    processes which make up a pipeline. Channels indicate
 *    the flow of data, i.e. the "route" that a file will take.
 */

// STAGE BAM FILES FROM TEST PROFILE # this establishes the test data to use with -profile test
if ( workflow.profile.tokenize(",").contains("test") ){

        include { check_test_data } from './lib/functions.nf' params(readPaths: params.readPaths, singleEnd: params.SE)
        INPUT = check_test_data(params.readPaths, params.SE)

} else {

    // STAGE INPUT CHANNELS # this defines the normal input when test profile is not in use
    INPUT = Channel...

}

////////////////////
// BEGIN WORKFLOW //
////////////////////

/*
 *   Workflows are where you define how different processes link together. They
 *    may be modularised into "sub-workflows" which must be named eg. 'DNAseq'
 *    and there must always be one MAIN workflow to link them together, which
 *    is always unnamed.
 */

// INCLUDES # here you must give the relevant sub-workflows from the modules/workflow directory 
include { workflow_name } from "${projectDir}/modules/workflow"

// MAIN WORKFLOW 
workflow {

    // call sub-workflows eg. workflow_1(Channel1, Channel2, Channel3, etc.)
    main:
        workflow_name(INPUT, file1, file2)

}




///////////////////
// INTROSPECTION //
///////////////////

// WORKFLOW TRACING # what to display when the pipeline finishes
// eg. message with errors
workflow.onError {
    log.info "Oops... Pipeline execution stopped with the following message: ${workflow.errorMessage}"
}

// eg. general completion message
workflow.onComplete {

    // maybe run a small clean-up script to remove "work" directory upon successful completion 
    if (!params.debug && workflow.success) {
        ["bash", "${baseDir}/bin/clean.sh", "${workflow.sessionId}"].execute() }

    include { printSummary } from './lib/functions.nf'
    printSummary()

}
