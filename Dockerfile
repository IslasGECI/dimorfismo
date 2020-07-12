FROM islasgeci/jupyter:3427

RUN Rscript -e "install.packages('rjson', repos='http://cran.rstudio.com')"

CMD make
