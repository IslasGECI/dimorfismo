FROM islasgeci/base:0.7.0
WORKDIR /workdir
RUN Rscript -e "install.packages(c('covr', 'lintr', 'rjson', 'roxygen2', 'styler', 'testthat'), repos='http://cran.rstudio.com')"
RUN R -e "devtools::document()" && \
    R CMD build . && \
    R CMD check dimorfismo_0.1.0.tar.gz && \
    R CMD INSTALL dimorfismo_0.1.0.tar.gz
COPY . .
CMD make
