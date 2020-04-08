FROM islasgeci/jupyter:3691

RUN curl -L http://mirrors.ctan.org/macros/latex/contrib/pythontex.zip --output /tmp/pythontex.zip && \
    unzip /tmp/pythontex.zip -d /tmp && \
    cd /tmp/pythontex && \
    latex pythontex.ins && \
    mkdir ~/texmf/tex --parents && \
    mv * ~/texmf/tex && \
    chmod +x ~/texmf/tex/pythontex.py && \
    ln --symbolic ~/texmf/tex/pythontex.py /usr/local/bin/pythonte

RUN Rscript -e 'install.packages("rjson", repos="http://cran.rstudio.com")'

CMD make
