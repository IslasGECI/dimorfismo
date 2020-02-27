<<<<<<< Updated upstream
FROM islasgeci/jupyter:8e52
=======
FROM islasgeci/jupyter:3691

RUN Rscript -e 'install.packages("rjson")'

>>>>>>> Stashed changes
CMD make
