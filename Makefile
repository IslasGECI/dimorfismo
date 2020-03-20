# Sección phonies
.PHONY: all clean 

all: reports/funcion_logistica.pdf results

clean:
	rm --force reports/*.aux
	rm --force reports/*.log
	rm --force reports/*.pdf
	rm --force --recursive data/processed

# Sección de objetivos principales
reports/funcion_logistica.pdf: reports/funcion_logistica.tex results
	pdflatex -output-directory=$(<D) $<
	pdflatex -output-directory=$(<D) $<

# Sección de requisitos de objetivos principales
results: data/raw/datapackage.json data/raw/morfometria_albatros-laysan_guadalupe.csv tabla_modelos_logisticos.csv tabla_mejores_modelos.csv parametros_mejor_modelo_logistico_laal_ig.json parametros_modelo_logistico_laal_ig.json

# Seccioón de objetivos individuales
tabla_modelos_logisticos.csv: src/dimorphism_model_class.R src/calculator_ROC_class.R src/evaluate_model_function.R src/get_prediction_sex_plot_function.R src/get_sex_probability_plot_function.R src/regretion_to_data_frame_coefficients_function.R
	mkdir --parents data/processed
	R --file=src/01_create_parameter_logistic_model_LAAL.R

tabla_mejores_modelos.csv: src/dimorphism_model_class.R src/calculator_ROC_class.R
	R --file=src/02_evaluate_better_models.R

parametros_mejor_modelo_logistico_laal_ig.json: src/dimorphism_model_class.R src/calculator_ROC_class.R
	R --file=src/02_evaluate_better_models.R

parametros_modelo_logistico_laal_ig.json: src/dimorphism_model_class.R src/calculator_ROC_class.R
	R --file=src/03_predict_sex.R
