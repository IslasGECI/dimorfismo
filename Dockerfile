FROM islasgeci/jupyter:ff82
WORKDIR /workdir
COPY . .
RUN Rscript -e "install.packages(c('covr', 'lintr', 'rjson', 'roxygen2', 'styler', 'testthat'), repos='http://cran.rstudio.com')"
RUN R -e "devtools::document()" && \
    R CMD build . && \
    R CMD check dimorfismo_0.1.0.tar.gz && \
    R CMD INSTALL dimorfismo_0.1.0.tar.gz
CMD make
