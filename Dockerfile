FROM islasgeci/jupyter:5869

RUN Rscript -e 'install.packages("rjson")'

CMD make
