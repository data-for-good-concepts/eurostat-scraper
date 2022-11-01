# Install base package
FROM rocker/r-ver

# User privileges
USER root

# Set environment variables
ENV RENV_VERSION 0.16.0
ENV RENV_PATHS_LIBRARY renv/library

# Install `renv` in order install package dependencies
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

# Set working directory
WORKDIR /usr/scraper

# Install required dependencies
RUN apt-get update --quiet \
    && apt-get -–install-suggests --assume-yes \
       libxml2-dev \
       default-jdk \
       firefox \
       libcurl4-openssl-dev \
       libicu-dev \
       wget \
       libz-dev \
    && wget https://github.com/mozilla/geckodriver/releases/download/v0.32.0/geckodriver-v0.32.0-linux64.tar.gz \
    && tar -xvzf geckodriver* \
    && chmod +x geckodriver

# First install devtools and CRAN version httpuv so that we have dependencies
RUN R -e "install.packages(c('devtools', 'httpuv'))"

COPY . .

# Install package dependencies
RUN R -e "renv::restore()"

EXPOSE 8080

ENTRYPOINT ["Rscript"]
CMD ["server.R"]

