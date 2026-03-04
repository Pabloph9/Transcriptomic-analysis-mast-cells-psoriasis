# ============================================================
# Dockerfile: RNA-seq Mast Cell Pipeline
# R version: 4.3.3
# Bioconductor: 3.18
# ============================================================


# 1. Base image

FROM rocker/tidyverse:4.3.3

LABEL maintainer="Pablo Rafael Pombero Hurtado"
LABEL description="Reproducible RNA-seq pipeline environment (Salmon + DESeq2 + Functional Analysis)"


# 2. Freeze CRAN snapshot (21 Feb 2026)

RUN echo "options(repos = c(CRAN='https://packagemanager.posit.co/cran/__linux__/jammy/2026-02-21'))" \
  >> /usr/local/lib/R/etc/Rprofile.site


# 3. System settings

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC


# 4. System dependencies

RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    openjdk-11-jre-headless \
    python3 \
    python3-pip \
    wget \
    curl \
    unzip \
    fastqc \
    trimmomatic \
    salmon \
    sra-toolkit \
    && rm -rf /var/lib/apt/lists/*


# 5. Python tools 

RUN pip3 install --no-cache-dir multiqc==1.33


# 6. Bioconductor R 4.3

RUN R -e "install.packages('BiocManager')" \
 && R -e "BiocManager::install(version='3.18', ask=FALSE)"


# 7. Install Bioconductor packages

RUN R -e "BiocManager::install(c( \
    'DESeq2', \
    'tximport', \
    'Biostrings', \
    'apeglm', \
    'EnhancedVolcano', \
    'org.Hs.eg.db', \
    'AnnotationDbi', \
    'clusterProfiler', \
    'enrichplot', \
    'pathview' \
), update=FALSE, ask=FALSE)"


# 8. CRAN packages

RUN R -e "install.packages(c( \
    'tidyverse', \
    'plotly', \
    'htmlwidgets', \
    'stringr', \
    'dplyr', \
    'ggplot2' \
))"


# 9. Verify installation

RUN R -e "library(DESeq2); library(tximport); library(clusterProfiler); library(ggplot2)"


# 10. Working directory

WORKDIR /project
COPY . .

CMD ["/bin/bash"]