FROM islasgeci/base:0.7.0
WORKDIR /workdir
COPY . .
RUN Rscript -e "install.packages(c('covr','DT','lintr', 'rjson', 'styler'), repos='http://cran.rstudio.com')"
CMD make
