all: tests reports/funcion_logistica.pdf

define runLint
	R -e "library(lintr)" \
      -e "lint('R/calculator_ROC_class.R', linters = with_defaults(line_length_linter(100)))" \
      -e "lint('R/dimorphism_model_class.R', linters = with_defaults(line_length_linter(100)))" \
      -e "lint('R/regretion_to_data_frame_coefficients_function.R', linters = with_defaults(line_length_linter(100)))" \
      -e "lint('src/01_create_parameter_logistic_model_LAAL.R', linters = with_defaults(line_length_linter(100)))" \
      -e "lint('src/02_evaluate_better_models.R', linters = with_defaults(line_length_linter(100)))" \
      -e "lint('src/03_predict_sex.R', linters = with_defaults(line_length_linter(100)))"
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
$(csvLogisticModelTable): src/01_create_parameter_logistic_model_LAAL.R $(RawData) R/dimorphism_model_class.R R/calculator_ROC_class.R R/regretion_to_data_frame_coefficients_function.R
	$(runScript)

$(csvBestModelTable) $(jsonBestLogisticModelParameters): src/02_evaluate_better_models.R $(RawData) $(csvLogisticModelTable) R/dimorphism_model_class.R R/calculator_ROC_class.R
	$(runScript)

$(jsonLogisticModelParameters): src/03_predict_sex.R $(RawData) $(csvBestModelTable) R/dimorphism_model_class.R R/calculator_ROC_class.R
	$(runScript)

# IV. Sección del resto de los phonies
# ------------------------------------------------------------------------------------------------
.PHONY: all lint clean tests coverage install

install:
	R -e "devtools::document()" && \
    R CMD build . && \
    R CMD check dimorfismo_0.1.0.tar.gz && \
    R CMD INSTALL dimorfismo_0.1.0.tar.gz

lint:
	$(runLint)
	$(runLint) | grep -e "\^" && exit 1 || exit 0

tests: $(jsonLogisticModelParameters)
	R -e "testthat::test_dir('tests/testthat/', report = 'summary', stop_on_failure = TRUE)" \
	  -e "devtools::test()"

coverage: $(jsonLogisticModelParameters)
	R -e "covr::package_coverage()"

# Elimina los residuos de LaTeX
clean:
	rm --force reports/*.aux
	rm --force reports/*.log
	rm --force reports/*.pdf
	rm --force reports/*.pytxcode
	rm --force --recursive data/processed
	rm --force --recursive reports/pythontex*
	rm --force *.tar.gz
	rm --force --recursive dimorfismo.Rcheck
	rm --force --recursive man
