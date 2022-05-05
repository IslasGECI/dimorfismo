FROM islasgeci/base:0.7.0
WORKDIR /workdir
COPY . .
RUN Rscript -e "install.packages(c('covr', 'lintr', 'rjson', 'roxygen2', 'styler', 'testthat'), repos='http://cran.rstudio.com')"
CMD make
