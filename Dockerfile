FROM islasgeci/jupyter:3691

RUN Rscript -e 'install.packages("rjson", repos="http://cran.rstudio.com")'

CMD make
