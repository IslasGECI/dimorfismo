FROM islasgeci/jupyter:3691

RUN Rscript -e 'install.packages("rjson")'

CMD make
