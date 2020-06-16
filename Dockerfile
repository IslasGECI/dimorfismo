FROM islasgeci/jupyter:ff82

RUN Rscript -e "install.packages(c('covr', 'rjson', 'testthat'), repos='http://cran.rstudio.com')"

CMD make
