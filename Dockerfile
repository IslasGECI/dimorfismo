FROM islasgeci/jupyter:ff82
WORKDIR /workdir
COPY . .
RUN Rscript -e "install.packages(c('covr', 'lintr', 'rjson', 'roxygen2', 'testthat'), repos='http://cran.rstudio.com')"
RUN R CMD build . && \
    R CMD check dimorfismo_0.1.0.tar.gz && \
    R CMD INSTALL dimorfismo_0.1.0.tar.gz
CMD make
