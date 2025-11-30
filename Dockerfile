FROM rocker/tidyverse:4.5.1

ENV DEBIAN_FRONTEND=noninteractive \
    R_LIBS_USER=/usr/local/lib/R/site-library

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev libxml2-dev libssl-dev libfontconfig1-dev \
    libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libxt6 zlib1g-dev \
    ca-certificates git && rm -rf /var/lib/apt/lists/*

# Install CRAN packages including tidyverse (ggplot2 + dplyr + more)
RUN R -e "install.packages(c('tidyverse','optparse','R.utils','data.table'), repos='https://cloud.r-project.org')"

# Install Bioconductor & maftools
RUN R -e "install.packages('BiocManager', repos='https://cloud.r-project.org'); \
           BiocManager::install(version='3.22'); \
           BiocManager::install('maftools', ask=FALSE)"

WORKDIR /pipeline
COPY bin/ /pipeline/bin/
RUN chmod +x /pipeline/bin/*.R

CMD ["bash"]
