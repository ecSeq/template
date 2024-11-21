#!/usr/bin/env nextflow

// INCLUDES # here you must give the relevant processes from the modules/process directory 
include { process_1;process_2;process_3;process_4;process_5 } from "${projectDir}/modules/process"

// SUB-WORKFLOWS
workflow 'workflow_name' {

    // take the initial Channels and paths (must be defined in main workflow)
    take:
        INPUT
        file1
        file2

    // here we define the structure of our workflow i.e. how the different processes lead into each other
    // eg. process(input1, input2, etc.)
    // eg. process.out[0], process.out[1], etc.
    // index numbers [0],[1],etc. refer to different outputs defined for processes in process.nf
    // You can forgo the index number if there is only 1 output.
    // ALWAYS PAY ATTENTION TO CARDINALITY!!

    main:
        // process_1 perhaps begins with the INPUT Channel (defined above)
        process_1(INPUT)
        // then process_2 perhaps works on the first output of process_1
        process_2(process_1.out[0])

        // process_3 perhaps works on the individual files only
        process_3(file1,file2)

        // perhaps now we need to combine different process outputs with some kind of Channel operator
        combined_outputs = process_1.out[0].combine(process_3.out)

        // maybe process_4 then uses the combined_channels as well as input files
        process_4(combined,file1,file2)

        // then finally process_5 works on the output of process_4
        process_5(process_4.out[0])

}