# I. Sección de objetivos principales
# ---------------------------------------------------------------------------------------------------
.PHONY: all clean 

all: reports/funcion_logistica.pdf results

# II. Sección de variables
# ------------------------------------------------------------------------------------------------
DatosCrudos = \
	data/raw/datapackage.json \
	data/raw/morfometria_albatros-laysan_guadalupe.csv

csvTablaModelosLogisticos= \
	data/processed/tabla_modelos_logisticos.csv

csvTablaMejoresModelos= \
	data/processed/tabla_mejores_modelos.csv

jsonParametrosMejorModeloLogistico= \
	data/processed/parametros_mejor_modelo_logistico_laal_ig.json

jsonParametrosModeloLogistico= \
	data/processed/parametros_modelo_logistico_laal_ig.json

# III. Sección de requisitos de objetivos principales:
# ------------------------------------------------------------------------------------------------
reports/funcion_logistica.pdf: reports/funcion_logistica.tex results
	pdflatex -output-directory=$(<D) $<
	pdflatex -output-directory=$(<D) $<

results: $(csvTablaModelosLogisticos) $(csvTablaMejoresModelos) $(jsonParametrosMejorModeloLogistico) $(jsonParametrosModeloLogistico)

# IV. Sección de dependencias para los objetivos principales
# ------------------------------------------------------------------------------------------------
$(csvTablaModelosLogisticos): $(DatosCrudos) src/dimorphism_model_class.R src/calculator_ROC_class.R src/evaluate_model_function.R src/get_prediction_sex_plot_function.R src/get_sex_probability_plot_function.R src/regretion_to_data_frame_coefficients_function.R
	mkdir --parents data/processed
	R --file=src/01_create_parameter_logistic_model_LAAL.R

$(csvTablaMejoresModelos) $(jsonParametrosMejorModeloLogistico): $(DatosCrudos) src/dimorphism_model_class.R src/calculator_ROC_class.R
	mkdir --parents data/processed
	R --file=src/02_evaluate_better_models.R

$(jsonParametrosModeloLogistico): $(DatosCrudos) src/dimorphism_model_class.R src/calculator_ROC_class.R
	mkdir --parents data/processed
	R --file=src/03_predict_sex.R

# V. Sección del resto de los phonies
# ------------------------------------------------------------------------------------------------
# Elimina los residuos de LaTeX

clean:
	rm --force reports/*.aux
	rm --force reports/*.log
	rm --force reports/*.pdf
	rm --force --recursive data/processed