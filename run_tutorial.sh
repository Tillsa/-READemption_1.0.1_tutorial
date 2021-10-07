#!/bin/bash

main(){
    readonly READEMPTION=reademption
    readonly READEMPTION_ANALYSIS_FOLDER=reademption_analysis
    readonly FTP_SOURCE=https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/210/855/GCF_000210855.2_ASM21085v2

    readonly MAPPING_PROCESSES=6
    readonly COVERAGE_PROCESSES=6
    readonly GENE_QUANTI_PROCESSES=6



    if [ ${#@} -eq 0 ]
    then
        echo "Specify function to call or 'all' for running all functions"
        echo "Avaible functions are: "
        grep "(){" run.sh | grep -v "^all()" |  grep -v "^main(){" |  grep -v "^#"  | grep -v 'grep "(){"' | sed "s/(){//"
    else
        "$@"
    fi
}

all(){
    ## running the analysis:
    create_reademtption_folder
    download_reference_sequences
    download_annotation
    download_and_subsample_reads
    align_reads
    build_coverage_files
    run_gene_quanti
    run_deseq
    viz_align
    viz_gene_quanti
    viz_deseq

}

## Running analysis


# create the reademption input and outputfolders inside the container
create_reademtption_folder(){
    $READEMPTION create -f $READEMPTION_ANALYSIS_FOLDER
}

# download the reference sequences to the reademption iput folder inside the container


download_reference_sequences(){
    wget -O ${READEMPTION_ANALYSIS_FOLDER}/input/reference_sequences/salmonella.fa.gz \
    ${FTP_SOURCE}/GCF_000210855.2_ASM21085v2_genomic.fna.gz
    gunzip ${READEMPTION_ANALYSIS_FOLDER}/input/reference_sequences/salmonella.fa.gz
}


download_annotation(){
    wget -O ${READEMPTION_ANALYSIS_FOLDER}/input/annotations/salmonella.gff.gz \
    ${FTP_SOURCE}/GCF_000210855.2_ASM21085v2_genomic.gff.gz
    gunzip ${READEMPTION_ANALYSIS_FOLDER}/input/annotations/salmonella.gff.gz
}
download_and_subsample_reads(){
      wget -P ${READEMPTION_ANALYSIS_FOLDER}/input/reads http://reademptiondata.imib-zinf.net/InSPI2_R1.fa.bz2
      wget -P ${READEMPTION_ANALYSIS_FOLDER}/input/reads http://reademptiondata.imib-zinf.net/InSPI2_R2.fa.bz2
      wget -P ${READEMPTION_ANALYSIS_FOLDER}/input/reads http://reademptiondata.imib-zinf.net/LSP_R1.fa.bz2
      wget -P ${READEMPTION_ANALYSIS_FOLDER}/input/reads http://reademptiondata.imib-zinf.net/LSP_R2.fa.bz2
}

align_reads(){
      $READEMPTION align \
			-p ${MAPPING_PROCESSES} \
			-a 95 \
			-l 20 \
			--poly_a_clipping \
			--progress \
			--split \
			     -f $READEMPTION_ANALYSIS_FOLDER

}

build_coverage_files(){
      $READEMPTION coverage \
      -p $COVERAGE_PROCESSES \
        -f $READEMPTION_ANALYSIS_FOLDER

    echo "coverage done"
}

run_gene_quanti(){
      $READEMPTION gene_quanti \
      -p $GENE_QUANTI_PROCESSES \
         -f $READEMPTION_ANALYSIS_FOLDER
    echo "gene quanti done"
}



run_deseq(){
			$READEMPTION deseq \
        -l InSPI2_R1.fa.bz2,InSPI2_R2.fa.bz2,LSP_R1.fa.bz2,LSP_R2.fa.bz2 \
        -c InSPI2,InSPI2,LSP,LSP \
           -f $READEMPTION_ANALYSIS_FOLDER
    echo "gene deseq done"
}

viz_align(){
  $READEMPTION viz_align\
           -f $READEMPTION_ANALYSIS_FOLDER
  echo "viz align done"
}

viz_gene_quanti(){
  $READEMPTION viz_gene_quanti\
           -f $READEMPTION_ANALYSIS_FOLDER
   echo "viz gene quanti"
}

viz_deseq(){
  $READEMPTION viz_deseq\
           -f $READEMPTION_ANALYSIS_FOLDER
   echo "viz deseq"
}

main $@
