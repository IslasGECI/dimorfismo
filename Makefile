all: tests 

define runScript
	mkdir --parents $(@D)
	R --file=$<
endef

# I. Sección de variables
# ------------------------------------------------------------------------------------------------
DatosCrudos = \
	data/raw/datapackage.json \
	data/raw/morfometria_albatros-laysan_guadalupe.csv 

csvTablaModelosLogisticos = \
	data/processed/tabla_modelos_logisticos.csv

csvTablaMejoresModelos = \
	data/processed/tabla_mejores_modelos.csv

jsonParametrosMejorModeloLogistico = \
	data/processed/parametros_mejor_modelo_logistico_laal_ig.json

jsonParametrosModeloLogistico = \
	data/processed/parametros_modelo_logistico_laal_ig.json

# II. Sección de requisitos de objetivos principales:
# ------------------------------------------------------------------------------------------------
reports/funcion_logistica.pdf: reports/funcion_logistica.tex $(csvTablaModelosLogisticos) $(csvTablaMejoresModelos) $(jsonParametrosMejorModeloLogistico) $(jsonParametrosModeloLogistico)
	cd $(<D) && pdflatex $(<F)
	cd $(<D) && pythontex $(<F)
	cd $(<D) && pdflatex $(<F)
	cd $(<D) && pdflatex $(<F)

# III. Sección de dependencias para los objetivos principales
# ------------------------------------------------------------------------------------------------
$(csvTablaModelosLogisticos): src/01_create_parameter_logistic_model_LAAL.R $(DatosCrudos) src/dimorphism_model_class.R src/calculator_ROC_class.R src/regretion_to_data_frame_coefficients_function.R
	$(runScript)

$(csvTablaMejoresModelos) $(jsonParametrosMejorModeloLogistico): src/02_evaluate_better_models.R $(DatosCrudos) $(csvTablaModelosLogisticos) src/dimorphism_model_class.R src/calculator_ROC_class.R
	$(runScript)

$(jsonParametrosModeloLogistico): src/03_predict_sex.R $(DatosCrudos) $(csvTablaMejoresModelos) src/dimorphism_model_class.R src/calculator_ROC_class.R
	$(runScript)

# IV. Sección del resto de los phonies
# ------------------------------------------------------------------------------------------------
.PHONY: all clean tests

# Elimina los residuos de LaTeX
clean:
	rm --force reports/*.aux
	rm --force reports/*.log
	rm --force reports/*.pdf
	rm --force reports/*.pytxcode
	rm --force --recursive data/processed
	rm --force --recursive reports/pythontex*

tests:
	R -e "testthat::test_dir('tests/testthat/', report = 'summary', stop_on_failure = TRUE)"