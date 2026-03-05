nextflow.enable.dsl=2

/*
========================================================
RNA-seq Differential Expression Pipeline
========================================================
*/

params.outdir = "results"

/*
--------------------------------------------------------
Workflow
--------------------------------------------------------
*/

workflow {

    start_ch = Channel.value(1)

    preprocessing_out = preprocessing(start_ch)

    quant_out = quantification(preprocessing_out)

    pca_out = tximport_pca(quant_out)

    deg_out = deseq2(pca_out)

    enrichment(deg_out)

}


/*
--------------------------------------------------------
Preprocessing
Download FASTQ, QC and trimming
--------------------------------------------------------
*/

process preprocessing {

    publishDir "${params.outdir}/logs", mode: 'copy'

    input:
    val start

    output:
    path "results/tmp_trimmed"

    script:
    """
    bash scripts/01_preprocessing.sh
    """
}


/*
--------------------------------------------------------
Salmon quantification
--------------------------------------------------------
*/

process quantification {

    publishDir "${params.outdir}/salmon_quants", mode: 'copy'

    input:
    path trimmed_reads

    output:
    path "results/salmon_quants"

    script:
    """
    bash scripts/02_quantification.sh
    """
}


/*
--------------------------------------------------------
Tximport + PCA
--------------------------------------------------------
*/

process tximport_pca {

    input:
    path quants

    output:
    path "results/figures"

    script:
    """
    Rscript scripts/03_tximport_pca.R
    """
}


/*
--------------------------------------------------------
Differential expression
--------------------------------------------------------
*/

process deseq2 {

    input:
    path figures

    output:
    path "results/tables"

    script:
    """
    Rscript scripts/04_deseq2_deg.R
    """
}


/*
--------------------------------------------------------
Functional enrichment
--------------------------------------------------------
*/

process enrichment {

    input:
    path tables

    output:
    path "results/figures/kegg_maps"

    script:
    """
    Rscript scripts/05_functional_enrichment.R
    """
}