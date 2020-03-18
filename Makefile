all: reports/funcion_logistica.pdf results

.PHONY: all clean results

reports/funcion_logistica.pdf: reports/funcion_logistica.tex
	pdflatex -output-directory=$(<D) $<

results: data/processed/parametros_mejor_modelo_logistico_laal_ig.json data/processed/tabla_mejores_modelos.csv data/processed/parametros_modelo_logistico_laal_ig.json data/processed/tabla_modelos_logisticos.csv

data/processed/parametros_mejor_modelo_logistico_laal_ig.json data/processed/tabla_mejores_modelos.csv data/processed/parametros_modelo_logistico_laal_ig.json data/processed/tabla_modelos_logisticos.csv: src/01_create_parameter_logistic_model_LAAL.R src/02_evaluate_better_models.R src/03_predict_sex.R
	mkdir --parents data/processed
	R --file=src/01_create_parameter_logistic_model_LAAL.R
	R --file=src/02_evaluate_better_models.R
	R --file=src/03_predict_sex.R

clean:
	rm --force reports/*.aux
	rm --force reports/*.log
	rm --force reports/*.pdf
	rm --force --recursive data/processed