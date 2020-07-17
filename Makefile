all: tests reports/funcion_logistica.pdf

define runLint
	R -e "library(lintr)" \
      -e "lint('src/01_create_parameter_logistic_model_LAAL.R', linters = with_defaults(line_length_linter(100)))" \
      -e "lint('src/02_evaluate_better_models.R', linters = with_defaults(line_length_linter(100)))" \
      -e "lint('src/03_predict_sex.R', linters = with_defaults(line_length_linter(100)))" \
      -e "lint('src/calculator_ROC_class.R', linters = with_defaults(line_length_linter(100)))" \
      -e "lint('src/dimorphism_model_class.R', linters = with_defaults(line_length_linter(100)))" \
      -e "lint('src/regretion_to_data_frame_coefficients_function.R', linters = with_defaults(line_length_linter(100)))"
endef

define runScript
	mkdir --parents $(@D)
	R --file=$<
endef

# I. Sección de variables
# ------------------------------------------------------------------------------------------------
RawData = \
	data/raw/datapackage.json \
	data/raw/laysan_albatross_morphometry_guadalupe.csv 

csvLogisticModelTable = \
	data/processed/logistic_model_table.csv

csvBestModelTable = \
	data/processed/best_models_table.csv

jsonBestLogisticModelParameters = \
	data/processed/best_logistic_model_parameters_laal_ig.json

jsonLogisticModelParameters = \
	data/processed/logistic_model_parameters.json

# II. Sección de requisitos de objetivos principales:
# ------------------------------------------------------------------------------------------------
reports/funcion_logistica.pdf: reports/logistic_function.tex $(csvLogisticModelTable) $(csvBestModelTable) $(jsonBestLogisticModelParameters) $(jsonLogisticModelParameters)
	cd $(<D) && pdflatex $(<F)
	cd $(<D) && pythontex $(<F)
	cd $(<D) && pdflatex $(<F)
	cd $(<D) && pdflatex $(<F)

# III. Sección de dependencias para los objetivos principales
# ------------------------------------------------------------------------------------------------
$(csvLogisticModelTable): src/01_create_parameter_logistic_model_LAAL.R $(RawData) src/dimorphism_model_class.R src/calculator_ROC_class.R src/regretion_to_data_frame_coefficients_function.R
	$(runScript)

$(csvBestModelTable) $(jsonBestLogisticModelParameters): src/02_evaluate_better_models.R $(RawData) $(csvLogisticModelTable) src/dimorphism_model_class.R src/calculator_ROC_class.R
	$(runScript)

$(jsonLogisticModelParameters): src/03_predict_sex.R $(RawData) $(csvBestModelTable) src/dimorphism_model_class.R src/calculator_ROC_class.R
	$(runScript)

# IV. Sección del resto de los phonies
# ------------------------------------------------------------------------------------------------
.PHONY: all lint clean tests coverage

lint:
	$(runLint)
	$(runLint) | grep -e "\^" && exit 1 || exit 0

tests: $(jsonLogisticModelParameters)
	R -e "testthat::test_dir('tests/testthat/', report = 'summary', stop_on_failure = TRUE)"

coverage: $(jsonLogisticModelParameters)
	R -e "covr::file_coverage(c(\
	'src/01_create_parameter_logistic_model_LAAL.R', \
	'src/02_evaluate_better_models.R', \
	'src/03_predict_sex.R', \
	'src/calculator_ROC_class.R', \
	'src/dimorphism_model_class.R', \
	'src/regretion_to_data_frame_coefficients_function.R' \
	),c(\
	'tests/testthat/tests_02_evaluate_better_models.R', \
	'tests/testthat/tests_regretion_to_data_frame_coefficients_function.R'))"

# Elimina los residuos de LaTeX
clean:
	rm --force reports/*.aux
	rm --force reports/*.log
	rm --force reports/*.pdf
	rm --force reports/*.pytxcode
	rm --force --recursive data/processed
	rm --force --recursive reports/pythontex*
