reports/funcion_logistica.pdf: reports/funcion_logistica.tex
	pdflatex -output-directory=$(<D) $<
	
clean:
	rm --force reports/*.aux
	rm --force reports/*.log
	rm --force reports/*.pdf