nextflow.enable.dsl=2

/*
========================================================
RNA-seq Differential Expression Pipeline
========================================================
*/

params.outdir = "results"

/*
--------------------------------------------------------
Preprocessing
Download FASTQ, QC and trimming
--------------------------------------------------------
*/
process preprocessing {

    publishDir "${params.outdir}/tmp_trimmed", mode: 'copy'

    input:
    val start

    output:
    path "*.fq.gz", emit: ch_trimmed_reads

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
    path ch_trimmed_reads

    output:
    path "*.sf", emit: ch_quants

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

    publishDir "${params.outdir}/figures", mode: 'copy'

    input:
    path ch_quants

    output:
    path "*.png", emit: ch_figures

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

    publishDir "${params.outdir}/tables", mode: 'copy'

    input:
    path ch_figures

    output:
    path "*.csv", emit: ch_tables_out

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

    publishDir "${params.outdir}/figures/kegg_maps", mode: 'copy'

    input:
    path ch_tables_out

    output:
    path "kegg_results/*", emit: ch_enrichment

    script:
    """
    Rscript scripts/05_functional_enrichment.R
    """
}

/*
--------------------------------------------------------
Workflow
--------------------------------------------------------
*/
workflow {

    start_ch = Channel.value(1)

    trimmed_ch = preprocessing(start_ch)
    quant_ch   = quantification(trimmed_ch)
    figures_ch = tximport_pca(quant_ch)
    tables_ch  = deseq2(figures_ch)
    enrichment(tables_ch)
}