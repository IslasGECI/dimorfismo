FROM islasgeci/jupyter:ff82
WORKDIR /workdir
COPY . .
RUN Rscript -e "install.packages(c('covr', 'lintr', 'rjson', 'testthat'), repos='http://cran.rstudio.com')"
CMD make
